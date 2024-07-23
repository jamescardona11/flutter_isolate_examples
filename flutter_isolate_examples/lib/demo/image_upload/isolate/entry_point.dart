import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_isolate_examples/demo/models/attachment_info.dart';
import 'package:path_provider/path_provider.dart';

import 'convert_image_to_base64.dart';
import 'isolate_in_messages.dart';
import 'mock_upload_image.dart';

abstract class EntryPointForUpload {
  static void entryPoint((SendPort, RootIsolateToken) sendPort) async {
    final rp = ReceivePort();
    sendPort.$1.send(rp.sendPort);

    BackgroundIsolateBinaryMessenger.ensureInitialized(sendPort.$2);
    final internalFolder = await _getInternalFolder();
    print('Saved to $internalFolder');

    final messages = rp.takeWhile((element) => element is IsolateMessage).cast<IsolateMessage>().switchMap(
      (message) {
        if (message is IsolateMessageData) {
          return Stream.fromIterable(message.data).map((event) => IsolateMessageData([event]));
        } else {
          return Stream.value(message);
        }
      },
    );

    final base64Converter = ConvertImageToBase64();
    final mockUploadImage = MockUploadImage();

    await for (final message in messages) {
      switch (message) {
        case IsolateMessageData _:
          // Early the original list of messages; was converted into multiple messages with a single item per list.
          // This help me to achieve a better control of the state of each item.
          // You can use another approach to achieve the same result.
          final data = message.data.first;
          sendPort.$1.send(data.updateState(AttachmentInfoState.uploading));
          final base64 = await base64Converter.convert(data.fileLocation);

          mockUploadImage.uploadImage(base64).then((value) {
            print('Uploaded');
            sendPort.$1.send(data.updateState(AttachmentInfoState.completed));
          }).catchError((error) {
            sendPort.$1.send(data.updateState(AttachmentInfoState.failed));
          });
          break;
        case IsolateMessagePause():
          print('[T] Paused');
          Isolate.current.pause(message.capability);
          break;
        case IsolateMessageResume():
          print('[T] Resumed');

          Isolate.current.resume(message.capability);
          break;
        case IsolateMessageClose _:
          print('[T] Closed');
          Isolate.exit(sendPort.$1, 'closed');
      }
    }
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

// SwitchMap operator; recommendation use RxDart
extension _SwitchMapStreamExtension<T> on Stream<T> {
  Stream<R> switchMap<R>(Stream<R> Function(T) mapper) {
    return transform(StreamTransformer<T, R>.fromHandlers(
      handleData: (T value, EventSink<R> sink) async {
        await mapper(value).forEach(sink.add);
      },
    ));
  }
}
