import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import '../../home/widgets/photo_viewer.dart';

class RecordCard extends StatelessWidget {
  const RecordCard({super.key, required this.record, this.onTap});

  final AttendanceRecord record;
  final VoidCallback? onTap;

  String _durationText(Duration duration) {
    return '${duration.inHours} jam ${duration.inMinutes.remainder(60)} menit';
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    final dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
    final duration = record.totalHours;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_available_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateFormat.format(record.date),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
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
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    constraints.maxWidth < 280 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20;
                return Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: stacked
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2,
                      child: _HistoryPhoto(
                        label: 'Masuk',
                        path: record.checkInPhotoPath,
                      ),
                    ),
                    SizedBox(
                      width: stacked
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2,
                      child: _HistoryPhoto(
                        label: 'Pulang',
                        path: record.checkOutPhotoPath,
                      ),
                    ),
                  ],
                );
              },
            ),
            if (onTap != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Lihat detail'),
                ),
              ),
            ],
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HistoryPhoto extends StatelessWidget {
  const _HistoryPhoto({required this.label, required this.path});

  final String label;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka foto $label',
      child: InkWell(
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
