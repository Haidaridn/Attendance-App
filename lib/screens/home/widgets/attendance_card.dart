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
    final theme = Theme.of(context);
    final currentRecord = record;
    if (currentRecord == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.schedule_outlined,
                  size: 30,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum ada presensi hari ini',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Mulai presensi Anda dengan mengambil foto masuk.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final timeFormat = DateFormat('HH:mm', 'id_ID');
    final completed = currentRecord.checkOutTime != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM y', 'id_ID').format(currentRecord.date),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  completed ? Icons.task_alt : Icons.login,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    completed ? 'Presensi selesai' : 'Sudah masuk',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final photos = [
                  _PhotoTile(
                    label: 'Foto masuk',
                    path: currentRecord.checkInPhotoPath,
                  ),
                  if (completed)
                    _PhotoTile(
                      label: 'Foto pulang',
                      path: currentRecord.checkOutPhotoPath,
                    ),
                ];
                final stacked =
                    constraints.maxWidth < 280 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20;
                return Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: photos
                      .map(
                        (photo) => SizedBox(
                          width: completed && !stacked
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth,
                          child: photo,
                        ),
                      )
                      .toList(),
                );
              },
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
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        runSpacing: 4,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
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
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 140 * MediaQuery.textScalerOf(context).scale(14) / 14,
                child: AttendancePhoto(path: path),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
