import 'dart:async';
import 'dart:isolate';

import 'package:flutter_isolate_examples/demo/models/attachment_info.dart';

import 'convert_image_to_base64.dart';
import 'mock_upload_image.dart';

/// Same controller as SpawnControllerExample2 but using Completer and different Entry point
class IsolateControllerForUpload<I, O> {
  final SendPort _commands;
  final ReceivePort _responses;

  final StreamController<O> _controller = StreamController<O>.broadcast();
  late final StreamSubscription<O> _subscription;

  IsolateControllerForUpload._(
    this._responses,
    this._commands,
  ) {
    _subscription = _responses //
        .takeWhile((element) => element is O)
        .cast<O>()
        .listen((event) {
      _controller.add(event);
    });
  }

  static Future<IsolateControllerForUpload<I, O>?> create<I, O>() async {
    final initPort = RawReceivePort();
    final connection = Completer<SendPort>.sync();
    initPort.handler = (initialMessage) {
      connection.complete(initialMessage as SendPort);
    };

    try {
      await Isolate.spawn(
        _entryPoint,
        initPort.sendPort,
        errorsAreFatal: true,
      );

      final SendPort sendPort = await connection.future;

      return IsolateControllerForUpload._(ReceivePort.fromRawReceivePort(initPort), sendPort);
    } catch (e) {
      initPort.close();
      print(e);
      return null;
    }
  }

  Stream<O> get broadcastRp => _controller.stream;

  void send(I message) {
    _commands.send(message);
  }

  void dispose() {
    _commands.send(IsolateMessageClose());
    _subscription.cancel();
    _responses.close();
  }
}

sealed class IsolateMessage {}

class IsolateMessageData extends IsolateMessage {
  final List<AttachmentInfo> data;

  IsolateMessageData(this.data);
}

class IsolateMessageClose extends IsolateMessage {}

void _entryPoint(SendPort sendPort) async {
  final rp = ReceivePort();
  sendPort.send(rp.sendPort);

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
        sendPort.send(data.updateState(AttachmentInfoState.uploading));
        final base64 = await base64Converter.convert(data.fileLocation);

        mockUploadImage.uploadImage(base64).then((value) {
          sendPort.send(data.updateState(AttachmentInfoState.completed));
        }).catchError((error) {
          sendPort.send(data.updateState(AttachmentInfoState.failed));
        });
        break;
      case IsolateMessageClose _:
        Isolate.exit(sendPort, 'closed');
    }
  }
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
