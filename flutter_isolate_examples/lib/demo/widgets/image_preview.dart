import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/demo/utils/attachment_info.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    Key? key,
    required this.attachment,
  }) : super(key: key);

  final AttachmentInfo attachment;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late File file;

  @override
  void initState() {
    file = File(widget.attachment.fileLocation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Image.file(
            file,
          ),
          if (widget.attachment.state == AttachmentInfoState.queued)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
              ),
              child: const Center(
                child: Text('Queued'),
              ),
            ),
          if (widget.attachment.state == AttachmentInfoState.uploading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
