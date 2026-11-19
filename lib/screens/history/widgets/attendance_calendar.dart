import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/attendance_statistics.dart';
import '../../../widgets/dashboard_widgets.dart';

class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({
    super.key,
    required this.month,
    required this.markedDays,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onDateSelected,
  });
  final DateTime month;
  final Set<int> markedDays;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final offset = DateTime(month.year, month.month).weekday - 1;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final rows = ((offset + days) / 7).ceil();
    final cell = math.max(
      48.0,
      MediaQuery.textScalerOf(context).scale(14) * 3 + 8,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            MonthSelector(month: month, onChanged: onMonthChanged),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = math.max(
                  constraints.maxWidth,
                  330 * MediaQuery.textScalerOf(context).scale(14) / 14,
                );
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            for (final name in [
                              'Sen',
                              'Sel',
                              'Rab',
                              'Kam',
                              'Jum',
                              'Sab',
                              'Min',
                            ])
                              SizedBox(
                                width: width / 7,
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (var row = 0; row < rows; row++)
                          Row(
                            children: [
                              for (var col = 0; col < 7; col++)
                                SizedBox(
                                  width: width / 7,
                                  height: cell,
                                  child: Builder(
                                    builder: (context) {
                                      final day = row * 7 + col - offset + 1;
                                      if (day < 1 || day > days) {
                                        return const SizedBox.shrink();
                                      }
                                      final date = DateTime(
                                        month.year,
                                        month.month,
                                        day,
                                      );
                                      final selected =
                                          selectedDate != null &&
                                          sameAttendanceDate(
                                            selectedDate!,
                                            date,
                                          );
                                      final hasRecord = markedDays.contains(
                                        day,
                                      );
                                      return Semantics(
                                        label:
                                            '${DateFormat('EEEE, d MMMM y', 'id_ID').format(date)}${hasRecord ? ', Ada presensi' : ''}',
                                        selected: selected,
                                        child: TextButton(
                                          key: ValueKey('calendar-date-$day'),
                                          onPressed: () => onDateSelected(date),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.all(4),
                                            backgroundColor: selected
                                                ? colors.primary
                                                : null,
                                            foregroundColor: selected
                                                ? colors.onPrimary
                                                : colors.onSurface,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '$day',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                key: hasRecord
                                                    ? ValueKey(
                                                        'calendar-record-$day',
                                                      )
                                                    : null,
                                                width: 4,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: hasRecord
                                                      ? (selected
                                                            ? colors.onPrimary
                                                            : colors.primary)
                                                      : Colors.transparent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Titik menandai tanggal dengan presensi.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
