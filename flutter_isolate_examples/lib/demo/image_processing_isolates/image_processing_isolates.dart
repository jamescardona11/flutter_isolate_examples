import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_isolate_examples/demo/utils/file_info.dart';
import 'package:path_provider/path_provider.dart';

import 'compress_service.dart';
import 'move_files.dart';

abstract class ImageProcessingIsolate {
  /// error handing is not implemented
  static Future<String?> compressImage(FileInfo info, {RootIsolateToken? token}) async {
    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    final helper = CompressImageService(info);

    final fileBytes = await _loadBytes(info.fileLocation);
    print('Original File with ${fileBytes.length} bytes');

    final newFileBytes = await helper.executeCompression(fileBytes);
    print('Compressed  with ${newFileBytes.length} bytes');

    final internalFolder = await _getInternalFolder();
    print('Saved to $internalFolder');

    return MoveFiles.saveInAppSystem(newFileBytes, internalFolder);
  }
}

Future<String> _getInternalFolder() async {
  final directory = await getApplicationDocumentsDirectory();

  if (!directory.existsSync()) {
    await directory.create();
  }

  final downloadDirectory = Directory('${directory.absolute.path}/images_folder');
  if (!downloadDirectory.existsSync()) {
    await downloadDirectory.create();
  }

  return downloadDirectory.absolute.path;
}

Future<Uint8List> _loadBytes(String path) async {
  // Read the file as bytes
  final file = File(path);
  Uint8List bytes = await file.readAsBytes();

  return bytes;
}
