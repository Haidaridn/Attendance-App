import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract class PhotoStorage {
  Future<String> savePhoto(String sourcePath, String photoType);
}

class StorageServices implements PhotoStorage {
  @override
  Future<String> savePhoto(String sourcePath, String photoType) async {
    if (photoType != 'checkin' && photoType != 'checkout') {
      throw ArgumentError.value(photoType, 'photoType');
    }

    final appDirectory = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(
      path.join(appDirectory.path, 'attendance_photos'),
    );
    await photoDirectory.create(recursive: true);

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${timestamp}_$photoType.jpg';
    final temporaryDirectory = await getTemporaryDirectory();
    final temporaryPath = path.join(
      temporaryDirectory.path,
      'compressed_$fileName',
    );
    final compressed = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      temporaryPath,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) {
      throw StateError('Foto gagal dikompresi.');
    }

    final destination = path.join(photoDirectory.path, fileName);
    final copiedFile = await File(compressed.path).copy(destination);
    await File(compressed.path).delete();
    return copiedFile.path;
  }

  // Meski bernama upload, versi ini hanya menyimpan lokal.
  Future<String> uploadAttendancePhoto(String sourcePath, String photoType) {
    return savePhoto(sourcePath, photoType);
  }
}
