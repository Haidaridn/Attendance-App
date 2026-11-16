import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import 'photo_viewer.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key, required this.record});

  final AttendanceRecord? record;

  String _durationText(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours jam $minutes menit';
  }

  @override
  Widget build(BuildContext context) {
    final currentRecord = record;
    if (currentRecord == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(Icons.schedule_outlined, size: 32),
              SizedBox(width: 16),
              Expanded(child: Text('Belum ada presensi hari ini')),
            ],
          ),
        ),
      );
    }

    final timeFormat = DateFormat('HH:mm', 'id_ID');
    final completed = currentRecord.checkOutTime != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  completed ? Icons.task_alt : Icons.login,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  completed ? 'Presensi selesai' : 'Sudah masuk',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TimeRow(
              label: 'Jam masuk',
              value: timeFormat.format(currentRecord.checkInTime),
            ),
            if (completed) ...[
              const SizedBox(height: 8),
              _TimeRow(
                label: 'Jam pulang',
                value: timeFormat.format(currentRecord.checkOutTime!),
              ),
              const SizedBox(height: 8),
              _TimeRow(
                label: 'Durasi',
                value: _durationText(currentRecord.totalHours!),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PhotoTile(
                    label: 'Foto masuk',
                    path: currentRecord.checkInPhotoPath,
                  ),
                ),
                if (completed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PhotoTile(
                      label: 'Foto pulang',
                      path: currentRecord.checkOutPhotoPath,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.value});

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

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.label, required this.path});

  final String label;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka $label',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => PhotoViewer(photoPath: path)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: AttendancePhoto(path: path),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
