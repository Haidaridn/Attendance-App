import 'package:flutter/material.dart';

import '../../main.dart' show buildAppTheme;

class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi Digital',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Builder(
        builder: (context) => Scaffold(
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
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.settings_suggest_outlined,
                              size: 32,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Presensi Digital',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Firebase belum dikonfigurasi',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          const Text('Selesaikan langkah berikut:'),
                          const SizedBox(height: 16),
                          ...const [
                            '1. Pasang Firebase CLI',
                            '2. Jalankan: firebase login',
                            '3. Jalankan: dart pub global activate '
                                'flutterfire_cli',
                            '4. Jalankan: flutterfire configure '
                                '--project=ID_PROJECT_ANDA',
                            '5. Jalankan ulang aplikasi',
                          ].map(
                            (step) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(step),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              errorMessage,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
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
      ),
    );
  }
}
