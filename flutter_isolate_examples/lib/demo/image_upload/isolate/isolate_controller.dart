import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';

import 'entry_point.dart';
import 'isolate_in_messages.dart';

/// Same controller as SpawnControllerExample2 but using Completer and different Entry point
class IsolateControllerForUpload<I, O> {
  final Isolate _isolate;
  final SendPort _commands;
  final ReceivePort _responses;

  final StreamController<O> _controller = StreamController<O>.broadcast();
  late final StreamSubscription<O> _subscription;

  IsolateControllerForUpload._(
    this._isolate,
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
    var rootToken = RootIsolateToken.instance!;

    final initPort = RawReceivePort();
    final connection = Completer<SendPort>.sync();
    initPort.handler = (initialMessage) {
      connection.complete(initialMessage as SendPort);
    };

    try {
      final isolate = await Isolate.spawn<(SendPort, RootIsolateToken)>(
        EntryPointForUpload.entryPoint,
        (initPort.sendPort, rootToken),
        errorsAreFatal: true,
      );

      final SendPort sendPort = await connection.future;

      return IsolateControllerForUpload._(isolate, ReceivePort.fromRawReceivePort(initPort), sendPort);
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

  void pause() {
    // _isolate.pause(pauseCapability);
    _commands.send(IsolateMessagePause(pauseCapability));
  }

  void resume() {
    _isolate.resume(pauseCapability);
    // _commands.send(IsolateMessageResume(pauseCapability));
    // _isolate.kill();
  }

  /// Capability granting the ability to pause the isolate (not implemented)
  Capability pauseCapability = Capability();

  void dispose() {
    _commands.send(IsolateMessageClose());
    _isolate.kill();
    _subscription.cancel();
    _responses.close();
  }
}

// Pause and resume, should be have the same capability
// you can pause inside the isolate and resume outside
// you can pause outside the isolate and resume outside