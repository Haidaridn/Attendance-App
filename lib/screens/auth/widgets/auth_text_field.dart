import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Label terpisah dapat membungkus pada layar sempit atau teks besar.
        final separateLabel =
            constraints.maxWidth < 260 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (separateLabel) ...[
              ExcludeSemantics(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Semantics(
              label: separateLabel ? label : null,
              child: TextFormField(
                controller: controller,
                validator: validator,
                obscureText: obscureText,
                keyboardType: keyboardType,
                autofillHints: obscureText
                    ? const [AutofillHints.password]
                    : const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: separateLabel ? null : label,
                  prefixIcon: Icon(
                    keyboardType == TextInputType.emailAddress
                        ? Icons.mail_outline_rounded
                        : Icons.lock_outline_rounded,
                  ),
                  suffixIcon: onToggleVisibility == null
                      ? null
                      : IconButton(
                          onPressed: onToggleVisibility,
                          tooltip: obscureText
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          icon: Icon(
                            obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.fact_check_outlined,
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Presensi Digital',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
