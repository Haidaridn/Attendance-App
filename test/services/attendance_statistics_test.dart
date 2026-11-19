import 'package:attendance_app/models/attendance_record.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:attendance_app/services/attendance_statistics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

AttendanceRecord record(
  String id,
  int day, {
  String uid = 'a',
  int? hours,
  int month = 11,
}) => AttendanceRecord(
  id: id,
  userId: uid,
  date: DateTime(2026, month, day),
  checkInTime: DateTime(2026, month, day, 8),
  checkOutTime: hours == null ? null : DateTime(2026, month, day, 8 + hours),
  checkInPhotoPath: '/in-$id.jpg',
  checkOutPhotoPath: hours == null ? null : '/out-$id.jpg',
);

void main() {
  final records = [
    record('first', 1, hours: 8),
    record('second', 2, hours: 6),
    record('open', 3),
    record('previous', 31, month: 10, hours: 9),
    record('other', 4, uid: 'b', hours: 10),
  ];

  test(
    'total dan rata-rata hanya dari record selesai UID dan bulan terpilih',
    () {
      final stats = AttendanceStatistics(
        records,
        userId: 'a',
        month: DateTime(2026, 11),
      );
      expect(stats.recordedDays, 3);
      expect(stats.completedCount, 2);
      expect(stats.openCount, 1);
      expect(stats.totalDuration, const Duration(hours: 14));
      expect(stats.averageDuration, const Duration(hours: 7));
      expect(stats.durationOn(DateTime(2026, 11, 1)), const Duration(hours: 8));
      expect(stats.durationOn(DateTime(2026, 11, 3)), Duration.zero);
    },
  );

  test('bulan kosong dan bulan tanpa record selesai menghasilkan nol', () {
    for (final stats in [
      AttendanceStatistics(records, userId: 'a', month: DateTime(2026, 12)),
      AttendanceStatistics(
        [record('open', 3)],
        userId: 'a',
        month: DateTime(2026, 11),
      ),
    ]) {
      expect(stats.completedCount, 0);
      expect(stats.totalDuration, Duration.zero);
      expect(stats.averageDuration, Duration.zero);
    }
  });

  test('filter bulan, tanggal, status, serta pengurutan terbaru', () {
    final filtered = selectAttendanceRecords(
      records,
      userId: 'a',
      month: DateTime(2026, 11),
    );
    expect(filtered.map((r) => r.id), ['open', 'second', 'first']);
    expect(
      selectAttendanceRecords(
        records,
        userId: 'a',
        status: AttendanceStatusFilter.completed,
      ).map((r) => r.id),
      ['second', 'first', 'previous'],
    );
    expect(
      selectAttendanceRecords(
        records,
        userId: 'a',
        status: AttendanceStatusFilter.open,
      ).single.id,
      'open',
    );
    expect(
      selectAttendanceRecords(
        records,
        userId: 'a',
        date: DateTime(2026, 11, 2),
      ).single.id,
      'second',
    );
    expect(records, hasLength(5));
  });

  test(
    'UID kosong tidak membaca data akun lain dan kalender hanya menandai record sendiri',
    () {
      expect(selectAttendanceRecords(records, userId: ''), isEmpty);
      expect(
        AttendanceStatistics(
          records,
          userId: '',
          month: DateTime(2026, 11),
        ).records,
        isEmpty,
      );
      expect(
        AttendanceStatistics(
          records,
          userId: 'a',
          month: DateTime(2026, 11),
        ).markedDays,
        {1, 2, 3},
      );
      expect(
        AttendanceStatistics(
          records,
          userId: 'b',
          month: DateTime(2026, 11),
        ).markedDays,
        {4},
      );
    },
  );

  test(
    'minggu kalender melintasi tahun dan seluruh minggu bulan terpilih tersedia',
    () {
      expect(attendanceWeekStart(DateTime(2027, 1, 1)), DateTime(2026, 12, 28));
      final weeks = attendanceWeeksInMonth(DateTime(2026, 11));
      expect(weeks.first, DateTime(2026, 10, 26));
      expect(weeks.last, DateTime(2026, 11, 30));
      expect(weeks.every((day) => day.weekday == DateTime.monday), isTrue);
    },
  );

  test(
    'notes ditambah, diubah, dan dikosongkan pada record yang sama serta tetap tersimpan',
    () async {
      SharedPreferences.setMockInitialValues({});
      final service = AttendanceService();
      final original = record('notes', 1, hours: 8);
      await service.createAttendanceRecord(original);
      for (final notes in ['Catatan pertama', 'Catatan diperbarui', '']) {
        final current = (await service.getAttendanceRecords('a').first).single;
        await service.updateAttendanceRecord(current.copyWith(notes: notes));
        final restored =
            (await AttendanceService().getAttendanceRecords('a').first).single;
        expect(restored.notes, notes);
        expect(restored.id, original.id);
        expect(restored.checkInTime, original.checkInTime);
        expect(restored.checkOutTime, original.checkOutTime);
        expect(restored.checkInPhotoPath, original.checkInPhotoPath);
        expect(restored.checkOutPhotoPath, original.checkOutPhotoPath);
        expect(await service.getAttendanceRecords('b').first, isEmpty);
      }
    },
  );
}
