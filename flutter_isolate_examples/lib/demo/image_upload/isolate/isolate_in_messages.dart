import 'dart:isolate';

import 'package:flutter_isolate_examples/demo/models/attachment_info.dart';

sealed class IsolateMessage {}

class IsolateMessageResume extends IsolateMessage {
  final Capability capability;

  IsolateMessageResume(this.capability);
}

class IsolateMessagePause extends IsolateMessage {
  final Capability capability;

  IsolateMessagePause(this.capability);
}

class IsolateMessageData extends IsolateMessage {
  final List<AttachmentInfo> data;

  IsolateMessageData(this.data);
}

class IsolateMessageClose extends IsolateMessage {}
