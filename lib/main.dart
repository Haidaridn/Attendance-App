import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'screens/config_error/config_error_screen.dart';
import 'services/attendance_service.dart';
import 'services/auth_services.dart';
import 'services/storage_services.dart';
import 'wrapper/auth_wrapper.dart';

const kSeedColor = Color(0xFF176B5B);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    runApp(ConfigErrorScreen(errorMessage: error.toString()));
    return;
  }

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatefulWidget {
  const AttendanceApp({super.key});

  @override
  State<AttendanceApp> createState() => _AttendanceAppState();
}

class _AttendanceAppState extends State<AttendanceApp> {
  late final AuthServices _authServices = AuthServices();
  late final AttendanceService _attendanceService = AttendanceService();
  late final PhotoStorage _photoStorage = StorageServices();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kSeedColor),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: AuthWrapper(
        authServices: _authServices,
        attendanceService: _attendanceService,
        photoStorage: _photoStorage,
      ),
    );
  }
}
