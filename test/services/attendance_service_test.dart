import 'package:attendance_app/models/attendance_record.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AttendanceService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = AttendanceService();
  });

  AttendanceRecord createRecord({required String id, required String userId}) {
    return AttendanceRecord(
      id: id,
      userId: userId,
      checkInTime: DateTime(2026, 11, 16, 8),
      date: DateTime(2026, 11, 16),
      checkInPhotoPath: '/foto/$id.jpg',
    );
  }

  test('stream langsung mengirim daftar kosong', () async {
    expect(await service.getAttendanceRecords('user-a').first, isEmpty);
  });

  test('catatan terisolasi berdasarkan userId', () async {
    await service.createAttendanceRecord(
      createRecord(id: 'record-a', userId: 'user-a'),
    );

    expect(await service.getAttendanceRecords('user-a').first, hasLength(1));
    expect(await service.getAttendanceRecords('user-b').first, isEmpty);
  });

  test('menolak dua presensi pengguna pada tanggal yang sama', () async {
    await service.createAttendanceRecord(
      createRecord(id: 'record-a', userId: 'user-a'),
    );

    expect(
      () => service.createAttendanceRecord(
        createRecord(id: 'record-b', userId: 'user-a'),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Presensi hari ini sudah ada.',
        ),
      ),
    );
  });

  test('pulang memperbarui record yang sama', () async {
    final record = createRecord(id: 'record-a', userId: 'user-a');
    await service.createAttendanceRecord(record);

    await service.updateAttendanceRecord(
      record.copyWith(
        checkOutTime: DateTime(2026, 11, 16, 16),
        checkOutPhotoPath: '/foto/pulang.jpg',
      ),
    );

    final records = await service.getAttendanceRecords('user-a').first;
    expect(records, hasLength(1));
    expect(records.single.id, 'record-a');
    expect(records.single.totalHours, const Duration(hours: 8));
  });
}
