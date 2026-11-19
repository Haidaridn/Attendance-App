import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/attendance_statistics.dart';
import '../../services/auth_services.dart';
import '../../widgets/dashboard_widgets.dart';
import 'attendance_detail_screen.dart';
import 'widgets/attendance_calendar.dart';
import 'widgets/record_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.userId,
    required this.attendanceService,
    this.authServices,
  });
  final String userId;
  final AttendanceService attendanceService;
  final AuthServices? authServices;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  AttendanceStatusFilter _status = AttendanceStatusFilter.all;
  late Stream<List<AttendanceRecord>> _records;

  @override
  void initState() {
    super.initState();
    _records = widget.attendanceService.getAttendanceRecords(widget.userId);
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.attendanceService != widget.attendanceService) {
      _records = widget.attendanceService.getAttendanceRecords(widget.userId);
      _selectedDate = null;
      _status = AttendanceStatusFilter.all;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Riwayat presensi')),
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
                    message: 'Riwayat gagal dimuat: ${snapshot.error}',
                    isError: true,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final own = selectAttendanceRecords(
                snapshot.data!,
                userId: widget.userId,
              );
              final statistics = AttendanceStatistics(
                own,
                userId: widget.userId,
                month: _month,
              );
              final records = selectAttendanceRecords(
                own,
                userId: widget.userId,
                month: _month,
                date: _selectedDate,
                status: _status,
              );
              return DashboardContent(
                children: [
                  Text(
                    'Jejak kehadiran Anda',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih tanggal atau status untuk menelusuri presensi.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  AttendanceCalendar(
                    month: _month,
                    markedDays: statistics.markedDays,
                    selectedDate: _selectedDate,
                    onMonthChanged: (month) => setState(() {
                      _month = month;
                      _selectedDate = null;
                    }),
                    onDateSelected: (date) => setState(
                      () => _selectedDate =
                          sameAttendanceDate(_selectedDate ?? DateTime(1), date)
                          ? null
                          : date,
                    ),
                  ),
                  if (_selectedDate != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedDate = null),
                      child: const Text('Tampilkan sebulan'),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final filter in AttendanceStatusFilter.values)
                        FilterChip(
                          label: Text(switch (filter) {
                            AttendanceStatusFilter.all => 'Semua',
                            AttendanceStatusFilter.completed => 'Selesai',
                            AttendanceStatusFilter.open => 'Belum Pulang',
                          }),
                          selected: _status == filter,
                          onSelected: (_) => setState(() => _status = filter),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (records.isEmpty)
                    DashboardMessage(
                      message: own.isEmpty
                          ? 'Belum ada riwayat presensi'
                          : 'Tidak ada presensi sesuai filter.',
                      icon: Icons.history_rounded,
                    ),
                  for (final record in records)
                    RecordCard(
                      record: record,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AttendanceDetailScreen(
                            recordId: record.id,
                            userId: widget.userId,
                            attendanceService: widget.attendanceService,
                            authServices: widget.authServices,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
  );
}
