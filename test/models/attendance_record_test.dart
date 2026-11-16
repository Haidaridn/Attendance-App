import 'package:attendance_app/models/attendance_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final checkIn = DateTime(2026, 11, 12, 8);
  final record = AttendanceRecord(
    id: 'record-1',
    userId: 'user-1',
    checkInTime: checkIn,
    date: DateTime(2026, 11, 12),
    checkInPhotoPath: '/foto/masuk.jpg',
  );

  test('toJson dan fromJson mempertahankan data', () {
    final restored = AttendanceRecord.fromJson(record.toJson());

    expect(restored.id, record.id);
    expect(restored.userId, record.userId);
    expect(restored.checkInTime, record.checkInTime);
    expect(restored.date, record.date);
    expect(restored.checkInPhotoPath, record.checkInPhotoPath);
  });

  test('tanggal JSON menggunakan format YYYY-MM-DD', () {
    expect(record.toJson()['date'], '2026-11-12');
  });

  test('copyWith melengkapi waktu pulang tanpa mengganti ID', () {
    final updated = record.copyWith(checkOutTime: DateTime(2026, 11, 12, 16));

    expect(updated.id, record.id);
    expect(updated.checkOutTime, DateTime(2026, 11, 12, 16));
  });

  test('totalHours null sebelum pulang', () {
    expect(record.totalHours, isNull);
  });

  test('totalHours menghasilkan 8 jam dari 08.00 sampai 16.00', () {
    final updated = record.copyWith(checkOutTime: DateTime(2026, 11, 12, 16));

    expect(updated.totalHours, const Duration(hours: 8));
  });

  test('totalHours menghasilkan 8 jam 30 menit', () {
    final timedRecord = AttendanceRecord(
      id: 'record-2',
      userId: 'user-1',
      checkInTime: DateTime(2026, 11, 12, 8, 15),
      checkOutTime: DateTime(2026, 11, 12, 16, 45),
      date: DateTime(2026, 11, 12),
    );

    expect(timedRecord.totalHours, const Duration(hours: 8, minutes: 30));
  });
}
