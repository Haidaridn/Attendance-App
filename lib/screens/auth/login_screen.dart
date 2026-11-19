import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_services.dart';
import 'register_screen.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authServices});

  final AuthServices authServices;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.authServices.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage('Gagal masuk: ${error.message ?? error.code}');
      }
    } catch (error) {
      if (mounted) _showMessage('Gagal masuk: $error');
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
                    title: 'Selamat datang kembali',
                    description: 'Masuk untuk mencatat kehadiran Anda.',
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
                                  value == null || value.isEmpty
                                  ? 'Kata sandi wajib diisi.'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Masuk'),
                            ),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => RegisterScreen(
                                          authServices: widget.authServices,
                                        ),
                                      ),
                                    ),
                              child: const Text('Belum punya akun? Daftar'),
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
