import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_services.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authServices});

  final AuthServices authServices;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.authServices.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage('Gagal mendaftar: ${error.message ?? error.code}');
      }
    } catch (error) {
      if (mounted) _showMessage('Gagal mendaftar: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar akun')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Mulai dengan akun Anda',
                    description: 'Daftar untuk mencatat presensi harian Anda.',
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Email wajib diisi.'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Kata sandi',
                              obscureText: _obscurePassword,
                              onToggleVisibility: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              validator: (value) =>
                                  value == null || value.length < 6
                                  ? 'Kata sandi minimal 6 karakter.'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _confirmationController,
                              label: 'Konfirmasi kata sandi',
                              obscureText: _obscurePassword,
                              validator: (value) =>
                                  value != _passwordController.text
                                  ? 'Konfirmasi kata sandi tidak cocok.'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _isLoading ? null : _register,
                              child: _isLoading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Daftar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
