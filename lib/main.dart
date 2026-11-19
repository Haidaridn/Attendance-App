import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'screens/config_error/config_error_screen.dart';
import 'services/attendance_service.dart';
import 'services/auth_services.dart';
import 'services/storage_services.dart';
import 'wrapper/auth_wrapper.dart';

const kSeedColor = Color(0xFF8BAF91);

// Satu tema untuk seluruh layar, termasuk panduan konfigurasi.
ThemeData buildAppTheme() {
  final colors =
      ColorScheme.fromSeed(
        seedColor: kSeedColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF35664B),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFDDE8D5),
        onPrimaryContainer: const Color(0xFF365B40),
        secondary: const Color(0xFF48674F),
        secondaryContainer: const Color(0xFFF9E8CA),
        onSecondaryContainer: const Color(0xFF775628),
        tertiaryContainer: const Color(0xFFE6E0F8),
        onTertiaryContainer: const Color(0xFF5F5186),
        surface: Colors.white,
        onSurface: const Color(0xFF24332A),
        onSurfaceVariant: const Color(0xFF64748B),
        surfaceContainerLow: const Color(0xFFF7F9F6),
        surfaceContainerHighest: const Color(0xFFEDF2EB),
        outline: const Color(0xFF64748B),
        outlineVariant: const Color(0xFFE5EBE4),
        error: const Color(0xFFDC2626),
      );
  final base = ThemeData(useMaterial3: true, colorScheme: colors);
  final text = base.textTheme.apply(
    bodyColor: colors.onSurface,
    displayColor: colors.onSurface,
  );
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  return base.copyWith(
    scaffoldBackgroundColor: colors.surfaceContainerLow,
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineSmall: text.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: text.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
      bodySmall: text.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.5,
        color: colors.onSurfaceVariant,
      ),
      labelLarge: text.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surfaceContainerLow,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: rounded,
        textStyle: text.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        minimumSize: const Size(48, 54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        side: BorderSide(color: colors.outlineVariant),
        shape: rounded,
        textStyle: text.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.onPrimaryContainer,
        minimumSize: const Size(48, 48),
        shape: rounded,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      prefixIconColor: colors.onSurfaceVariant,
      suffixIconColor: colors.onSurfaceVariant,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.secondary, width: 1.5),
      ),
      errorMaxLines: 3,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      contentTextStyle: text.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
        height: 1.5,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.onSurface,
      shape: rounded,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.secondary),
    navigationBarTheme: NavigationBarThemeData(
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? colors.primary
              : colors.onSurfaceVariant,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.outlineVariant,
      thickness: 1,
      space: 1,
    ),
  );
}

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
      theme: buildAppTheme(),
      home: AuthWrapper(
        authServices: _authServices,
        attendanceService: _attendanceService,
        photoStorage: _photoStorage,
      ),
    );
  }
}
