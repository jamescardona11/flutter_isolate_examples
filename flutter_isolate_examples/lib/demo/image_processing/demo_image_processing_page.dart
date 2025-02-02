import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/demo/models/file_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'isolate/image_processing_isolates.dart';

class DemoImageProcessingPage extends StatefulWidget {
  const DemoImageProcessingPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DemoImageProcessingPage> createState() => _DemoImageProcessingPageState();
}

class _DemoImageProcessingPageState extends State<DemoImageProcessingPage> {
  String? originalPath;
  String? newPath;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Image Processing Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (originalPath != null) Image.file(File(originalPath!)),
            TextButton(
              onPressed: () async {
                final xfile = await _picker.pickImage(source: ImageSource.gallery);
                originalPath = xfile?.path;
                setState(() {});
              },
              child: const Text('Pick Image'),
            ),
            TextButton(
              onPressed: () async {
                if (originalPath == null) return;
                var rootToken = RootIsolateToken.instance!;

                // get the file location
                newPath = await compute(
                  ImageProcessingIsolate.compressImage,
                  FileInfo(
                    maxSize: 1 * 1024 * 1024,
                    fileLocation: originalPath!,
                    token: rootToken,
                  ),
                ); // <<1MB

                setState(() {});
              },
              child: const Text('Run isolate'),
            ),
            if (newPath != null) Image.file(File(newPath!)),
          ],
        ),
      ),
    );
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

abstract class ImageProcessingIsolates {
  final int id;
  final double maxSize;

  ImageProcessingIsolates(this.id, this.maxSize);

  // Create function to calculate the max size of the image
  static double calculateMaxSize(int id, double maxSize) {
    return maxSize;
  }
}
