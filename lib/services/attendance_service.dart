import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_record.dart';

class AttendanceService {
  AttendanceService({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  static const _storageKey = 'local_attendance_records_v1';

  final Future<SharedPreferences> _preferences;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  final List<AttendanceRecord> _records = [];
  Future<void>? _storageInitialization;

  Future<void> _initStorage() {
    return _storageInitialization ??= _loadStorage();
  }

  Future<void> _loadStorage() async {
    final preferences = await _preferences;
    final storedRecords = preferences.getString(_storageKey);
    if (storedRecords == null) return;

    final decoded = jsonDecode(storedRecords) as List<dynamic>;
    _records
      ..clear()
      ..addAll(
        decoded.map(
          (item) => AttendanceRecord.fromJson(item as Map<String, dynamic>),
        ),
      );
  }

  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) async* {
    await _initStorage();
    yield _recordsForUser(userId);
    yield* _changes.stream.map((_) => _recordsForUser(userId));
  }

  Stream<AttendanceRecord?> getTodayRecordStream(String userId) async* {
    await _initStorage();
    yield _todayRecord(userId);
    yield* _changes.stream.map((_) => _todayRecord(userId));
  }

  Future<String> createAttendanceRecord(AttendanceRecord record) async {
    await _initStorage();
    final alreadyExists = _records.any(
      (item) =>
          item.userId == record.userId && _isSameDate(item.date, record.date),
    );
    if (alreadyExists) {
      throw StateError('Presensi hari ini sudah ada.');
    }

    final recordId = record.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : record.id;
    _records.add(record.copyWith(id: recordId));
    try {
      await _persistRecords();
    } catch (_) {
      _records.removeWhere((item) => item.id == recordId);
      rethrow;
    }
    _emitUpdates();
    return recordId;
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    await _initStorage();
    final index = _records.indexWhere(
      (item) => item.id == record.id && item.userId == record.userId,
    );
    if (index == -1) {
      throw StateError('Data presensi tidak ditemukan.');
    }

    final previous = _records[index];
    _records[index] = record;
    try {
      await _persistRecords();
    } catch (_) {
      _records[index] = previous;
      rethrow;
    }
    _emitUpdates();
  }

  Future<void> _persistRecords() async {
    final preferences = await _preferences;
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(_records.map((record) => record.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Data presensi gagal disimpan.');
    }
  }

  void _emitUpdates() => _changes.add(null);

  List<AttendanceRecord> _recordsForUser(String userId) {
    return _records.where((record) => record.userId == userId).toList();
  }

  AttendanceRecord? _todayRecord(String userId) {
    final now = DateTime.now();
    for (final record in _records.reversed) {
      if (record.userId == userId && _isSameDate(record.date, now)) {
        return record;
      }
    }
    return null;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
