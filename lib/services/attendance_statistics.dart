import '../models/attendance_record.dart';

enum AttendanceStatusFilter { all, completed, open }

bool sameAttendanceDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// Semua tampilan turunan memakai UID yang sama; tidak ada cache statistik kedua.
List<AttendanceRecord> selectAttendanceRecords(
  Iterable<AttendanceRecord> records, {
  required String userId,
  DateTime? month,
  DateTime? date,
  AttendanceStatusFilter status = AttendanceStatusFilter.all,
}) {
  if (userId.isEmpty) return [];
  return records.where((record) {
    return record.userId == userId &&
        (month == null ||
            (record.date.year == month.year &&
                record.date.month == month.month)) &&
        (date == null || sameAttendanceDate(record.date, date)) &&
        (status != AttendanceStatusFilter.completed ||
            record.checkOutTime != null) &&
        (status != AttendanceStatusFilter.open || record.checkOutTime == null);
  }).toList()..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
}

class AttendanceStatistics {
  AttendanceStatistics(
    Iterable<AttendanceRecord> records, {
    required String userId,
    required DateTime month,
  }) : records = selectAttendanceRecords(records, userId: userId, month: month);

  final List<AttendanceRecord> records;

  int get recordedDays => records
      .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
      .toSet()
      .length;
  int get completedCount => records.where((r) => r.checkOutTime != null).length;
  int get openCount => records.length - completedCount;
  Duration get totalDuration => records.fold(
    Duration.zero,
    (sum, r) => sum + (r.totalHours ?? Duration.zero),
  );
  Duration get averageDuration => completedCount == 0
      ? Duration.zero
      : Duration(
          microseconds: (totalDuration.inMicroseconds / completedCount).round(),
        );

  Set<int> get markedDays => records.map((r) => r.date.day).toSet();

  Duration durationOn(DateTime day) => records
      .where((r) => sameAttendanceDate(r.date, day))
      .fold(Duration.zero, (sum, r) => sum + (r.totalHours ?? Duration.zero));
}

DateTime attendanceWeekStart(DateTime day) =>
    DateTime(day.year, day.month, day.day - day.weekday + 1);

List<DateTime> attendanceWeeksInMonth(DateTime month) {
  final weeks = <DateTime>[];
  var week = attendanceWeekStart(DateTime(month.year, month.month));
  final end = DateTime(month.year, month.month + 1);
  while (week.isBefore(end)) {
    weeks.add(week);
    week = DateTime(week.year, week.month, week.day + 7);
  }
  return weeks;
}

String attendanceDurationText(Duration duration) =>
    '${duration.inHours} jam ${duration.inMinutes.remainder(60)} menit';
