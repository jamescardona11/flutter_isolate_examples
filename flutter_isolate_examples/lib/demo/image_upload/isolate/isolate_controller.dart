import 'dart:async';
import 'dart:isolate';

import 'entry_point.dart';
import 'isolate_in_messages.dart';

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
        EntryPointForUpload.entryPoint,
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
