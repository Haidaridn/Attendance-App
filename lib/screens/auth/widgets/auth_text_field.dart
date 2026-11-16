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
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: obscureText
          ? const [AutofillHints.password]
          : const [AutofillHints.email],
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: onToggleVisibility == null
            ? null
            : IconButton(
                onPressed: onToggleVisibility,
                tooltip: obscureText
                    ? 'Tampilkan kata sandi'
                    : 'Sembunyikan kata sandi',
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              ),
      ),
    );
  }
}
