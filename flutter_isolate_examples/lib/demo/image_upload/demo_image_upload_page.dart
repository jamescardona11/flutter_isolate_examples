import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/demo/image_upload/provider/upload_image_provider.dart';

import 'image_picker_page/image_picker_page.dart';

class DemoImageUploadPage extends StatefulWidget {
  const DemoImageUploadPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DemoImageUploadPage> createState() => _DemoImageUploadPageState();
}

class _DemoImageUploadPageState extends State<DemoImageUploadPage> {
  final UploadImageProvider _provider = UploadImageProvider();

  @override
  void initState() {
    super.initState();
    _provider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, child) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImagePickerPage(
                          provider: _provider,
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Image Picker Page'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Images: ${_provider.totalCount}'),
                      const SizedBox(width: 20),
                      Text('Completed ${_provider.completedCount}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createIsolate() async {}

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }
}
