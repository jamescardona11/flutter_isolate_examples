import 'dart:io';

import 'package:flutter/services.dart';

class MoveFiles {
  static Future<String?> saveInAppSystem(Uint8List bytes, String newPath) async {
    final image = '$newPath/image.jpg';
    try {
      // Create a new file in the app's document directory

      File newFile = File(image);
      final e = await newFile.exists();
      if (e) {
        await newFile.delete();
      }

      newFile = File(image);
      await newFile.parent.create(recursive: true);
      await newFile.writeAsBytes(bytes);

      // Return the new file path
      return newFile.path;
    } catch (e) {
      return null;
    }
  }
}
