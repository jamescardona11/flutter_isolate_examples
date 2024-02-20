import 'package:flutter_isolate_examples/demo/models/attachment_info.dart';

sealed class IsolateMessage {}

class IsolateMessageData extends IsolateMessage {
  final List<AttachmentInfo> data;

  IsolateMessageData(this.data);
}

class IsolateMessageClose extends IsolateMessage {}
