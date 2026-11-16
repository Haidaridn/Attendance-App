import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import 'widgets/record_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.userId,
    required this.attendanceService,
  });

  final String userId;
  final AttendanceService attendanceService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat presensi')),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: attendanceService.getAttendanceRecords(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Riwayat gagal dimuat: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = List<AttendanceRecord>.of(snapshot.data!)
            ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
          if (records.isEmpty) {
            return const Center(child: Text('Belum ada riwayat presensi'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) => RecordCard(record: records[index]),
          );
        },
      ),
    );
  }
}
