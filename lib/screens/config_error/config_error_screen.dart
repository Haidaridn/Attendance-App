import 'package:flutter/material.dart';

import '../../main.dart' show kSeedColor;

class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kSeedColor),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.settings_suggest_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Firebase belum dikonfigurasi',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        const Text('Selesaikan langkah berikut:'),
                        const SizedBox(height: 8),
                        const Text('1. Pasang Firebase CLI'),
                        const Text('2. Jalankan: firebase login'),
                        const Text(
                          '3. Jalankan: dart pub global activate '
                          'flutterfire_cli',
                        ),
                        const Text(
                          '4. Jalankan: flutterfire configure '
                          '--project=ID_PROJECT_ANDA',
                        ),
                        const Text('5. Jalankan ulang aplikasi'),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
