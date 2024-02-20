import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class ConvertImageToBase64 {
  Future<String> convert(String path) async {
    final fileBytes = await _loadBytes(path);

    return base64Encode(fileBytes);
  }

  Future<Uint8List> _loadBytes(String path) async {
    // Read the file as bytes
    final file = File(path);
    Uint8List bytes = await file.readAsBytes();

    return bytes;
  }
}
