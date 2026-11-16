import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import '../../home/widgets/photo_viewer.dart';

class RecordCard extends StatelessWidget {
  const RecordCard({super.key, required this.record});

  final AttendanceRecord record;

  String _durationText(Duration duration) {
    return '${duration.inHours} jam ${duration.inMinutes.remainder(60)} menit';
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    final dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
    final duration = record.totalHours;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(record.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Masuk',
              value: timeFormat.format(record.checkInTime),
            ),
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Pulang',
              value: record.checkOutTime == null
                  ? 'Belum pulang'
                  : timeFormat.format(record.checkOutTime!),
            ),
            if (duration != null) ...[
              const SizedBox(height: 6),
              _InfoRow(label: 'Durasi', value: _durationText(duration)),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _HistoryPhoto(
                    label: 'Masuk',
                    path: record.checkInPhotoPath,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HistoryPhoto(
                    label: 'Pulang',
                    path: record.checkOutPhotoPath,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _HistoryPhoto extends StatelessWidget {
  const _HistoryPhoto({required this.label, required this.path});

  final String label;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PhotoViewer(photoPath: path)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Foto $label', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: AttendancePhoto(path: path),
            ),
          ),
        ],
      ),
    );
  }
}
