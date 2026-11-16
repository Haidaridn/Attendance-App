import 'package:attendance_app/screens/config_error/config_error_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('menampilkan panduan saat Firebase belum dikonfigurasi', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ConfigErrorScreen(errorMessage: 'Konfigurasi tidak ditemukan'),
    );

    expect(find.text('Firebase belum dikonfigurasi'), findsOneWidget);
    expect(find.textContaining('flutterfire configure'), findsOneWidget);
    expect(find.text('Konfigurasi tidak ditemukan'), findsOneWidget);
  });
}
