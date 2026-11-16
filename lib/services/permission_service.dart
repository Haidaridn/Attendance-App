import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> requestCameraPermission() {
    return Permission.camera.request();
  }

  Future<bool> openSettings() => openAppSettings();
}
