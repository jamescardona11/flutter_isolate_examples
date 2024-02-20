import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/demo/image_upload/provider/upload_image_provider.dart';
import 'package:flutter_isolate_examples/demo/models/attachment_info.dart';
import 'package:image_picker/image_picker.dart';

import 'image_preview.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({
    Key? key,
    required this.provider,
  }) : super(key: key);

  final UploadImageProvider provider;

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.provider,
          builder: (context, child) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final xfiles = await _picker.pickMultiImage();
                    widget.provider.addAttachments(xfiles.map((xfile) => AttachmentInfo.queued(xfile.path)).toList());
                  },
                  child: const Text('Pick Image'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Images: ${widget.provider.totalCount}'),
                      const SizedBox(width: 20),
                      Text('Completed ${widget.provider.completedCount}'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: widget.provider.totalCount,
                    itemBuilder: (context, index) {
                      final attachment = widget.provider.attachments[index];

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
      ),
    );
  }
}
