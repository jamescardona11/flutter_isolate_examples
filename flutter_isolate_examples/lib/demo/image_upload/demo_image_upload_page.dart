import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/demo/models/attachment_info.dart';
import 'package:image_picker/image_picker.dart';

import 'image_picker_page/image_preview.dart';
import 'isolate/isolate_controller.dart';

class DemoImageUploadPage extends StatefulWidget {
  const DemoImageUploadPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DemoImageUploadPage> createState() => _DemoImageUploadPageState();
}

class _DemoImageUploadPageState extends State<DemoImageUploadPage> {
  final ImagePicker _picker = ImagePicker();
  final List<AttachmentInfo> _attachments = [];

  StreamSubscription? subscription;
  IsolateControllerForUpload<IsolateMessage, AttachmentInfo>? isolateController;

  @override
  void initState() {
    super.initState();
    createIsolate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  final xfiles = await _picker.pickMultiImage();

                  _attachments.addAll(xfiles.map((xfile) => AttachmentInfo.queued(xfile.path)));

                  setState(() {});
                },
                child: const Text('Pick Image'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Images: ${_attachments.length}'),
                    const SizedBox(width: 20),
                    Text('Completed ${_attachments.where((element) => element.state == AttachmentInfoState.completed).length}'),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: _attachments.length,
                  itemBuilder: (context, index) {
                    final attachment = _attachments[index];

                    return Padding(
                      key: ValueKey(attachment.id),
                      padding: const EdgeInsets.all(8.0),
                      child: ImagePreview(
                        attachment: attachment,
                      ),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createIsolate() async {
    isolateController = await IsolateControllerForUpload.create();
    subscription = isolateController?.broadcastRp.listen((message) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    isolateController?.dispose();
    super.dispose();
  }
}
