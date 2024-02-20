import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_isolate_examples/demo/image_upload/isolate/isolate_controller.dart';
import 'package:flutter_isolate_examples/demo/image_upload/isolate/isolate_in_messages.dart';
import 'package:flutter_isolate_examples/demo/models/attachment_info.dart';

class UploadImageProvider extends ChangeNotifier {
  final Map<String, AttachmentInfo> _attachments = {};
  IsolateControllerForUpload<IsolateMessage, AttachmentInfo>? _isolateController;
  StreamSubscription? _subscription;

  void init() async {
    _isolateController = await IsolateControllerForUpload.create();
    _subscription = _isolateController?.broadcastRp.listen((attachment) {
      _attachments[attachment.id] = attachment;
      notifyListeners();
    });
  }

  void addAttachments(List<AttachmentInfo> attachments) {
    for (final attachment in attachments) {
      _attachments[attachment.id] = attachment;
    }
    _isolateController?.send(IsolateMessageData(attachments));

    notifyListeners();
  }

  List<AttachmentInfo> get attachments => _attachments.values.toList();

  int get completedCount => _attachments.values.where((element) => element.state == AttachmentInfoState.completed).length;
  int get totalCount => _attachments.length;

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _isolateController?.dispose();
  }
}
