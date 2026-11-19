import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/attendance_statistics.dart';
import '../../services/auth_services.dart';
import '../../widgets/dashboard_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({
    super.key,
    required this.userId,
    required this.attendanceService,
    this.authServices,
  });
  final String userId;
  final AttendanceService attendanceService;
  final AuthServices? authServices;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _week = attendanceWeekStart(DateTime.now());
  late final _records = widget.attendanceService.getAttendanceRecords(
    widget.userId,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Statistik')),
    body:
        widget.userId.isEmpty ||
            (widget.authServices != null &&
                widget.authServices!.currentUser?.uid != widget.userId)
        ? const Center(
            child: DashboardMessage(message: 'Sesi akun telah berubah.'),
          )
        : StreamBuilder<List<AttendanceRecord>>(
            stream: _records,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: DashboardMessage(
                    message: 'Statistik gagal dimuat: ${snapshot.error}',
                    isError: true,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = AttendanceStatistics(
                snapshot.data!,
                userId: widget.userId,
                month: _month,
              );
              final weeks = attendanceWeeksInMonth(_month);
              final weekIndex = weeks.indexWhere(
                (w) => sameAttendanceDate(w, _week),
              );
              return DashboardContent(
                children: [
                  Text(
                    'Kehadiran dalam angka',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ringkasan dari presensi pribadi yang tersimpan di perangkat ini.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  MonthSelector(
                    month: _month,
                    onChanged: (month) => setState(() {
                      _month = month;
                      _week = attendanceWeeksInMonth(month).first;
                    }),
                  ),
                  const SizedBox(height: 20),
                  MetricGrid(
                    children: [
                      MetricCard(
                        label: 'Hari tercatat',
                        value: '${stats.recordedDays}',
                        icon: Icons.event_available_outlined,
                      ),
                      MetricCard(
                        label: 'Selesai',
                        value: '${stats.completedCount}',
                        icon: Icons.task_alt_rounded,
                        tone: 1,
                      ),
                      MetricCard(
                        label: 'Belum pulang',
                        value: '${stats.openCount}',
                        icon: Icons.schedule_rounded,
                        tone: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Durasi mingguan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Minggu sebelumnya',
                                onPressed: weekIndex > 0
                                    ? () => setState(
                                        () => _week = weeks[weekIndex - 1],
                                      )
                                    : null,
                                icon: const Icon(Icons.chevron_left_rounded),
                              ),
                              Expanded(
                                child: Text(
                                  '${DateFormat('d MMM', 'id_ID').format(_week)} – ${DateFormat('d MMM', 'id_ID').format(DateTime(_week.year, _week.month, _week.day + 6))}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Minggu berikutnya',
                                onPressed: weekIndex < weeks.length - 1
                                    ? () => setState(
                                        () => _week = weeks[weekIndex + 1],
                                      )
                                    : null,
                                icon: const Icon(Icons.chevron_right_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          WeeklyDurationChart(statistics: stats, week: _week),
                          const SizedBox(height: 16),
                          Text(
                            'Durasi dalam jam, hanya dari presensi selesai pada bulan terpilih. Hari kosong tidak berarti tidak hadir.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waktu yang tercatat',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Total durasi',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            attendanceDurationText(stats.totalDuration),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rata-rata presensi selesai',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            attendanceDurationText(stats.averageDuration),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (stats.records.isEmpty)
                    const DashboardMessage(
                      message: 'Belum ada presensi pada bulan ini.',
                      icon: Icons.bar_chart_rounded,
                    ),
                ],
              );
            },
          ),
  );
}

class WeeklyDurationChart extends StatelessWidget {
  const WeeklyDurationChart({
    super.key,
    required this.statistics,
    required this.week,
  });
  final AttendanceStatistics statistics;
  final DateTime week;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      7,
      (i) => DateTime(week.year, week.month, week.day + i),
    );
    final maxMinutes = days.fold(
      60,
      (value, day) => math.max(value, statistics.durationOn(day).inMinutes),
    );
    final cellWidth = math.max(
      36.0,
      MediaQuery.textScalerOf(context).scale(12) * 3 + 8,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, cellWidth * 7);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in days)
                  SizedBox(
                    width: width / 7,
                    child: Builder(
                      builder: (context) {
                        final duration = statistics.durationOn(day);
                        final completed = statistics.records.any(
                          (r) =>
                              sameAttendanceDate(r.date, day) &&
                              r.checkOutTime != null,
                        );
                        final description =
                            '${DateFormat('EEEE, d MMMM', 'id_ID').format(day)}: ${completed ? attendanceDurationText(duration) : 'Belum ada durasi selesai'}';
                        return Semantics(
                          label: description,
                          child: Tooltip(
                            message: description,
                            child: ExcludeSemantics(
                              child: Column(
                                children: [
                                  Text(
                                    completed
                                        ? NumberFormat(
                                            '0.#',
                                            'id_ID',
                                          ).format(duration.inMinutes / 60)
                                        : '—',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 112,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: 22,
                                        height: completed
                                            ? math.max(
                                                4.0,
                                                112 *
                                                    duration.inMinutes /
                                                    maxMinutes,
                                              )
                                            : 4,
                                        decoration: BoxDecoration(
                                          color: completed
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.outlineVariant,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('E', 'id_ID').format(day),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${day.day}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
