import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import '../../../services/attendance_statistics.dart';
import '../../../services/attendance_service.dart';
import '../../../widgets/dashboard_widgets.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({
    super.key,
    required this.attendanceService,
    required this.userId,
    required this.onHistory,
    required this.onStatistics,
    required this.onDetail,
  });
  final AttendanceService attendanceService;
  final String userId;
  final VoidCallback onHistory;
  final VoidCallback onStatistics;
  final ValueChanged<AttendanceRecord> onDetail;

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  late final _records = widget.attendanceService.getAttendanceRecords(
    widget.userId,
  );

  @override
  Widget build(BuildContext context) => StreamBuilder<List<AttendanceRecord>>(
    stream: _records,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return DashboardMessage(
          message: 'Ringkasan gagal dimuat: ${snapshot.error}',
          isError: true,
        );
      }
      if (!snapshot.hasData) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        );
      }
      final own = selectAttendanceRecords(
        snapshot.data!,
        userId: widget.userId,
      );
      final stats = AttendanceStatistics(
        own,
        userId: widget.userId,
        month: DateTime.now(),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            title: 'Ringkasan bulan ini',
            action: 'Statistik',
            onAction: widget.onStatistics,
          ),
          Text(
            DateFormat('MMMM y', 'id_ID').format(DateTime.now()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
          SectionHeading(
            title: 'Aktivitas terakhir',
            action: 'Riwayat',
            onAction: widget.onHistory,
          ),
          if (own.isEmpty)
            const DashboardMessage(
              message: 'Belum ada riwayat presensi',
              icon: Icons.history_rounded,
            ),
          for (final record in own.take(3))
            InkWell(
              onTap: () => widget.onDetail(record),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                      child: Icon(
                        record.checkOutTime == null
                            ? Icons.login_rounded
                            : Icons.task_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, d MMM',
                              'id_ID',
                            ).format(record.date),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Masuk ${DateFormat('HH:mm', 'id_ID').format(record.checkInTime)} · ${record.checkOutTime == null ? 'Belum pulang' : 'Selesai'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}
