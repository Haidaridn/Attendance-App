import 'package:attendance_app/screens/home/widgets/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dialog keluar tampil dan Batal menutup dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (_) => const LogoutDialog(),
              ),
              child: const Text('Buka dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari akun?'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari akun?'), findsNothing);
  });
}
