import 'package:attendance_app/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserProfile dapat diserialisasi dan dideserialisasi', () {
    final profile = UserProfile(
      id: 'user-1',
      email: 'pengguna@example.com',
      fullName: 'Pengguna Contoh',
      createdAt: DateTime(2026, 11, 12, 7, 30),
    );

    final json = profile.toJson();
    final restored = UserProfile.fromJson(json);

    expect(json['full_name'], 'Pengguna Contoh');
    expect(json['created_at'], '2026-11-12T07:30:00.000');
    expect(restored.id, profile.id);
    expect(restored.email, profile.email);
    expect(restored.fullName, profile.fullName);
    expect(restored.createdAt, profile.createdAt);
    expect(restored.role, 'Pengguna');
  });
}
