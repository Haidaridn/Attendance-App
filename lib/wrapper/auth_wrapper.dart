import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/attendance_service.dart';
import '../services/auth_services.dart';
import '../services/storage_services.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({
    super.key,
    required this.authServices,
    required this.attendanceService,
    required this.photoStorage,
  });

  final AuthServices authServices;
  final AttendanceService attendanceService;
  final PhotoStorage photoStorage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authServices.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Status akun gagal dimuat: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (snapshot.data == null) {
          return LoginScreen(authServices: authServices);
        }
        return HomeScreen(
          key: ValueKey(snapshot.data!.uid),
          authServices: authServices,
          attendanceService: attendanceService,
          photoStorage: photoStorage,
        );
      },
    );
  }
}
