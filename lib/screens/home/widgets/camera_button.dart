import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/permission_service.dart';
import '../../../services/storage_services.dart';
import 'action_button.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({
    super.key,
    required this.label,
    required this.photoType,
    required this.photoStorage,
    required this.onCaptureStarted,
    required this.onPhotoSaved,
    required this.onCancelled,
    required this.onError,
    this.isLoading = false,
    this.permissionService,
  });

  final String label;
  final String photoType;
  final PhotoStorage photoStorage;
  final VoidCallback onCaptureStarted;
  final Future<void> Function(String path) onPhotoSaved;
  final VoidCallback onCancelled;
  final void Function(Object error) onError;
  final bool isLoading;
  final PermissionService? permissionService;

  Future<void> _capture(BuildContext context, {bool started = false}) async {
    if (!started) onCaptureStarted();
    try {
      final permissions = permissionService ?? PermissionService();
      final status = await permissions.requestCameraPermission();
      if (!context.mounted) return;

      if (status.isPermanentlyDenied || status.isRestricted) {
        await _showPermanentDenialDialog(context, permissions);
        onCancelled();
        return;
      }
      if (!status.isGranted) {
        final retry = await _showDenialDialog(context);
        if (!context.mounted) return;
        if (retry) {
          await _capture(context, started: true);
        } else {
          onCancelled();
        }
        return;
      }

      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        onCancelled();
        return;
      }
      final savedPath = await photoStorage.savePhoto(image.path, photoType);
      await onPhotoSaved(savedPath);
    } catch (error) {
      onError(error);
    }
  }

  Future<bool> _showDenialDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.camera_alt_outlined),
            title: const Text('Izin kamera diperlukan'),
            content: const Text(
              'Foto wajib untuk mencatat presensi. Berikan izin kamera untuk '
              'melanjutkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showPermanentDenialDialog(
    BuildContext context,
    PermissionService permissions,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.camera_alt_outlined),
        title: const Text('Aktifkan izin kamera'),
        content: const Text(
          'Izin kamera dinonaktifkan permanen. Buka pengaturan aplikasi dan '
          'aktifkan izin kamera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              await permissions.openSettings();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Buka pengaturan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      label: label,
      icon: Icons.camera_alt_outlined,
      isLoading: isLoading,
      onPressed: isLoading ? null : () => _capture(context),
    );
  }
}
