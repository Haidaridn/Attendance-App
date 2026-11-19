import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: children,
        ),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ],
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tone = 0,
  });
  final String label;
  final String value;
  final IconData icon;
  final int tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = [
      colors.primaryContainer,
      colors.secondaryContainer,
      colors.tertiaryContainer,
    ][tone % 3];
    final foreground = [
      colors.onPrimaryContainer,
      colors.onSecondaryContainer,
      colors.onTertiaryContainer,
    ][tone % 3];
    return Container(
      constraints: const BoxConstraints(minHeight: 144),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(color: foreground),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: foreground,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
      final columns = largeText ? 1 : (constraints.maxWidth >= 330 ? 3 : 2);
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.onChanged,
  });
  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Bulan sebelumnya',
        onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Expanded(
        child: Text(
          DateFormat('MMMM y', 'id_ID').format(month),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      IconButton(
        tooltip: 'Bulan berikutnya',
        onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class DashboardMessage extends StatelessWidget {
  const DashboardMessage({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.isError = false,
  });
  final String message;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 32,
          color: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}
