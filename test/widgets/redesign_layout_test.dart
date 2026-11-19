import 'package:attendance_app/main.dart';
import 'package:attendance_app/models/attendance_record.dart';
import 'package:attendance_app/screens/auth/login_screen.dart';
import 'package:attendance_app/screens/auth/register_screen.dart';
import 'package:attendance_app/screens/config_error/config_error_screen.dart';
import 'package:attendance_app/screens/history/history_screen.dart';
import 'package:attendance_app/screens/home/home_screen.dart';
import 'package:attendance_app/screens/home/widgets/action_button.dart';
import 'package:attendance_app/screens/home/widgets/photo_viewer.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/services/storage_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// Data uji hanya untuk memeriksa UI; tidak menginisialisasi Firebase/kamera.
class LayoutFirebaseAuth implements FirebaseAuth {
  @override
  User get currentUser => LayoutUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class LayoutUser implements User {
  @override
  String get uid => 'layout-user';

  @override
  String get email => 'pengguna.dengan.alamat.email.panjang@contoh.id';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class LayoutAttendanceService implements AttendanceService {
  LayoutAttendanceService(this.record);

  final AttendanceRecord? record;

  @override
  Stream<AttendanceRecord?> getTodayRecordStream(String userId) =>
      Stream.value(record);

  @override
  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) =>
      Stream.value([?record]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class LayoutPhotoStorage implements PhotoStorage {
  @override
  Future<String> savePhoto(String sourcePath, String photoType) =>
      throw UnsupportedError('Kamera tidak dipakai dalam pengujian layout.');
}

AttendanceRecord layoutRecord({bool completed = false}) => AttendanceRecord(
  id: 'layout-record',
  userId: 'layout-user',
  date: DateTime(2026, 11, 18),
  checkInTime: DateTime(2026, 11, 18, 8, 15),
  checkOutTime: completed ? DateTime(2026, 11, 18, 16, 45) : null,
);

Widget layoutApp(Widget screen, {double textScale = 1, double keyboard = 0}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: child!,
      ),
      home: screen,
    );

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  for (final size in [const Size(320, 720), const Size(390, 844)]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('layout ${size.width}px, teks $scale tanpa overflow', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final auth = AuthServices(firebaseAuth: LayoutFirebaseAuth());

        // Semua status harus tetap menyediakan tindakan sesuai record.
        for (final record in [
          null,
          layoutRecord(),
          layoutRecord(completed: true),
        ]) {
          await tester.pumpWidget(
            layoutApp(
              HomeScreen(
                key: UniqueKey(),
                authServices: auth,
                attendanceService: LayoutAttendanceService(record),
                photoStorage: LayoutPhotoStorage(),
              ),
              textScale: scale,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (record?.checkOutTime != null) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -2500),
            );
            await tester.pumpAndSettle();
            expect(find.byType(ActionButton), findsNothing);
          } else {
            await tester.scrollUntilVisible(find.byType(ActionButton), 300);
            await tester.pumpAndSettle();
            expect(find.byType(ActionButton), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        }

        for (final screen in [
          LoginScreen(authServices: auth),
          RegisterScreen(authServices: auth),
          HistoryScreen(
            userId: 'layout-user',
            attendanceService: LayoutAttendanceService(
              layoutRecord(completed: true),
            ),
          ),
          HistoryScreen(
            userId: 'layout-user',
            attendanceService: LayoutAttendanceService(null),
          ),
          const PhotoViewer(photoPath: null),
        ]) {
          await tester.pumpWidget(layoutApp(screen, textScale: scale));
          await tester.pumpAndSettle();
          if (find.byType(Scrollable).evaluate().isNotEmpty) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -2500),
            );
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull);
        }

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(scale),
            ),
            child: const ConfigErrorScreen(
              errorMessage: 'Konfigurasi tidak ditemukan',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('form tetap dapat digulir saat keyboard dan validasi tampil', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final auth = AuthServices(firebaseAuth: LayoutFirebaseAuth());

    for (final screen in [
      LoginScreen(authServices: auth),
      RegisterScreen(authServices: auth),
    ]) {
      await tester.pumpWidget(layoutApp(screen, textScale: 2, keyboard: 280));
      await tester.pumpAndSettle();
      final button = find.byType(FilledButton);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Email wajib diisi.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('foto riwayat membuka viewer dengan placeholder dan zoom', (
    tester,
  ) async {
    await tester.pumpWidget(
      layoutApp(
        HistoryScreen(
          userId: 'layout-user',
          attendanceService: LayoutAttendanceService(
            layoutRecord(completed: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Kalender v2 berada di atas daftar; gulir ke record sebelum memeriksa foto.
    await tester.scrollUntilVisible(
      find.text('Foto Masuk'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('08:15'), findsOneWidget);
    expect(find.text('16:45'), findsOneWidget);
    expect(find.text('8 jam 30 menit'), findsOneWidget);
    await tester.tap(find.text('Foto Masuk'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoViewer), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('Foto tidak tersedia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
