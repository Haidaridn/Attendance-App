import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(email.isEmpty ? '?' : email[0].toUpperCase()),
        ),
        title: const Text('Akun aktif'),
        subtitle: Text(email),
      ),
    );
  }
}
