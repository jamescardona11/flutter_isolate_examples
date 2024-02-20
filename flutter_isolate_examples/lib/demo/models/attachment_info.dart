import 'package:uuid/uuid.dart';

class AttachmentInfo {
  final String id;
  final String fileLocation;
  final AttachmentInfoState state;

  const AttachmentInfo._({
    required this.id,
    required this.fileLocation,
    required this.state,
  });

  factory AttachmentInfo.queued(String fileLocation) {
    final id = Uuid().v4();
    return AttachmentInfo._(
      id: id,
      fileLocation: fileLocation,
      state: AttachmentInfoState.queued,
    );
  }

  AttachmentInfo updateState(AttachmentInfoState state) {
    return AttachmentInfo._(
      id: id,
      fileLocation: fileLocation,
      state: state,
    );
  }
}

enum AttachmentInfoState { queued, uploading, completed, failed }
