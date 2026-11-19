import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class PhotoViewer extends StatelessWidget {
  const PhotoViewer({super.key, required this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18221D),
      appBar: AppBar(
        title: const Text('Foto presensi'),
        backgroundColor: const Color(0xFF18221D),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: AttendancePhoto(path: photoPath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class AttendancePhoto extends StatelessWidget {
  const AttendancePhoto({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  final String? path;
  final BoxFit fit;

  Uint8List? _decodeBase64(String value) {
    try {
      final normalized = value.contains(',') ? value.split(',').last : value;
      return base64Decode(normalized);
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = path;
    if (value != null && value.isNotEmpty) {
      final localFile = File(value);
      if (localFile.existsSync()) {
        return Image.file(
          localFile,
          fit: fit,
          errorBuilder: (_, _, _) => const PhotoPlaceholder(),
        );
      }

      final bytes = _decodeBase64(value);
      if (bytes != null) {
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (_, _, _) => const PhotoPlaceholder(),
        );
      }
    }
    return const PhotoPlaceholder();
  }
}

class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 28,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Foto tidak tersedia',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
