import 'dart:async';

import 'package:attendance_app/models/attendance_record.dart';
import 'package:attendance_app/screens/history/attendance_detail_screen.dart';
import 'package:attendance_app/screens/history/history_screen.dart';
import 'package:attendance_app/screens/home/home_screen.dart';
import 'package:attendance_app/screens/profile/profile_screen.dart';
import 'package:attendance_app/screens/statistics/statistics_screen.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/widgets/dashboard_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'redesign_layout_test.dart' as layout;

class V2User extends layout.LayoutUser {
  V2User(this.id);
  final String id;
  @override
  String get uid => id;
}

class V2FirebaseAuth implements FirebaseAuth {
  User? active = V2User('a');
  final changes = StreamController<User?>.broadcast();
  @override
  User? get currentUser => active;
  @override
  Stream<User?> authStateChanges() async* {
    yield active;
    yield* changes.stream;
  }

  @override
  Future<void> signOut() async {
    active = null;
    changes.add(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class V2AttendanceService extends AttendanceService {
  bool failUpdates = false;
  @override
  Future<void> updateAttendanceRecord(AttendanceRecord record) {
    if (failUpdates) throw StateError('Penyimpanan tidak tersedia');
    return super.updateAttendanceRecord(record);
  }
}

AttendanceRecord v2Record(
  String id,
  int day, {
  String uid = 'a',
  bool completed = false,
}) {
  final now = DateTime.now();
  return AttendanceRecord(
    id: id,
    userId: uid,
    date: DateTime(now.year, now.month, day),
    checkInTime: DateTime(now.year, now.month, day, 8),
    checkOutTime: completed ? DateTime(now.year, now.month, day, 16) : null,
  );
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  late V2AttendanceService service;
  late V2FirebaseAuth firebase;
  late AuthServices auth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    firebase = V2FirebaseAuth();
    auth = AuthServices(firebaseAuth: firebase);
  });
  tearDown(() {
    unawaited(firebase.changes.close());
  });

  Future<void> seed() async {
    service = V2AttendanceService();
    await service.createAttendanceRecord(v2Record('done', 3, completed: true));
    await service.createAttendanceRecord(v2Record('open', 5));
    await service.createAttendanceRecord(v2Record('other', 7, uid: 'b'));
  }

  testWidgets(
    'navigasi empat tab, filter kalender/status, dan detail presensi',
    (tester) async {
      await seed();
      await tester.pumpWidget(
        layout.layoutApp(
          HomeScreen(
            authServices: auth,
            attendanceService: service,
            photoStorage: layout.LayoutPhotoStorage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle();
      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.text('16 jam 0 menit'), findsNothing);
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('calendar-record-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('calendar-record-5')), findsOneWidget);
      expect(find.byKey(const ValueKey('calendar-record-7')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('calendar-date-3')));
      await tester.pumpAndSettle();
      final openFilter = find.widgetWithText(FilterChip, 'Belum Pulang');
      await tester.scrollUntilVisible(
        openFilter,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(openFilter);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Tidak ada presensi sesuai filter.'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada presensi sesuai filter.'), findsOneWidget);
      await tester.ensureVisible(find.widgetWithText(FilterChip, 'Selesai'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Selesai'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Lihat detail'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Lihat detail'), findsOneWidget);
      await tester.tap(find.text('Lihat detail'));
      await tester.pumpAndSettle();
      expect(find.byType(AttendanceDetailScreen), findsOneWidget);
      expect(find.text('Presensi selesai'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).at(3));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      await tester.tap(find.byType(NavigationDestination).first);
      await tester.pumpAndSettle();
      expect(find.text('Halo, selamat datang'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'catatan tersimpan, dapat diubah, dan kegagalan tidak dianggap berhasil',
    (tester) async {
      await seed();
      await tester.pumpWidget(
        layout.layoutApp(
          AttendanceDetailScreen(
            recordId: 'done',
            userId: 'a',
            attendanceService: service,
            authServices: auth,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(TextField), 300);
      await tester.enterText(find.byType(TextField), 'Catatan pertama');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Simpan catatan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan catatan'));
      await tester.pumpAndSettle();
      var own = await service.getAttendanceRecords('a').first;
      expect(own, hasLength(2));
      expect(own.singleWhere((r) => r.id == 'done').notes, 'Catatan pertama');
      expect(find.text('Catatan berhasil disimpan.'), findsOneWidget);
      ScaffoldMessenger.of(
        tester.element(find.byType(TextField)),
      ).clearSnackBars();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Catatan kedua');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan catatan'));
      await tester.pumpAndSettle();
      own = await service.getAttendanceRecords('a').first;
      expect(own.singleWhere((r) => r.id == 'done').notes, 'Catatan kedua');
      expect(
        own.singleWhere((r) => r.id == 'done').totalHours,
        const Duration(hours: 8),
      );
      ScaffoldMessenger.of(
        tester.element(find.byType(TextField)),
      ).clearSnackBars();
      await tester.pumpAndSettle();
      service.failUpdates = true;
      await tester.enterText(find.byType(TextField), 'Tidak tersimpan');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan catatan'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Catatan gagal disimpan:'), findsOneWidget);
      expect(
        (await service.getAttendanceRecords('a').first)
            .singleWhere((r) => r.id == 'done')
            .notes,
        'Catatan kedua',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dashboard mengikuti stream dan membatasi aktivitas terbaru hingga tiga',
    (tester) async {
      await seed();
      await tester.pumpWidget(
        layout.layoutApp(
          HomeScreen(
            authServices: auth,
            attendanceService: service,
            photoStorage: layout.LayoutPhotoStorage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Hari tercatat'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<MetricCard>(find.byType(MetricCard).first).value,
        '2',
      );
      await service.createAttendanceRecord(v2Record('new', 9, completed: true));
      await service.createAttendanceRecord(
        v2Record('newest', 10, completed: true),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<MetricCard>(find.byType(MetricCard).first).value,
        '4',
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'detail menolak record UID lain dan membersihkan tampilan saat sesi berganti',
    (tester) async {
      await seed();
      await tester.pumpWidget(
        layout.layoutApp(
          AttendanceDetailScreen(
            recordId: 'other',
            userId: 'a',
            attendanceService: service,
            authServices: auth,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Data presensi tidak ditemukan.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.pumpWidget(
        layout.layoutApp(
          AttendanceDetailScreen(
            key: UniqueKey(),
            recordId: 'done',
            userId: 'a',
            attendanceService: service,
            authServices: auth,
          ),
        ),
      );
      await tester.pumpAndSettle();
      firebase.active = V2User('b');
      firebase.changes.add(firebase.active);
      await tester.pumpAndSettle();
      expect(
        find.text('Sesi akun berubah. Buka kembali presensi dari akun aktif.'),
        findsOneWidget,
      );
      expect(find.text('Presensi selesai'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets('seluruh layar v2 pada 320 px dan teks $scale tanpa overflow', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await seed();
      for (final screen in [
        StatisticsScreen(
          userId: 'a',
          attendanceService: service,
          authServices: auth,
        ),
        ProfileScreen(authServices: auth, attendanceService: service),
        HistoryScreen(
          userId: 'a',
          attendanceService: service,
          authServices: auth,
        ),
        AttendanceDetailScreen(
          recordId: 'done',
          userId: 'a',
          attendanceService: service,
          authServices: auth,
        ),
      ]) {
        await tester.pumpWidget(layout.layoutApp(screen, textScale: scale));
        await tester.pumpAndSettle();
        final scrollable = find.byType(Scrollable).first;
        for (var i = 0; i < 10; i++) {
          await tester.drag(scrollable, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
    });
  }

  testWidgets('statistik dan riwayat kosong tetap menjelaskan keadaan data', (
    tester,
  ) async {
    service = V2AttendanceService();
    await tester.pumpWidget(
      layout.layoutApp(
        StatisticsScreen(userId: 'a', attendanceService: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Belum ada presensi pada bulan ini.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('0 jam 0 menit'), findsNWidgets(2));
    await tester.pumpWidget(
      layout.layoutApp(HistoryScreen(userId: 'a', attendanceService: service)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Belum ada riwayat presensi'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Belum ada riwayat presensi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
