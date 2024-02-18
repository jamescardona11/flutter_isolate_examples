import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

class IsolatesService {
  void computeIsolate() {
    print('Compute');
    compute(doSomething, 1000000000);
  }

  void spawn() async {
    print('Spawn');
    final rcvPort = ReceivePort();

    final isolate = await Isolate.spawn(_doSomethingForSpawn, rcvPort.sendPort);

    final completer = Completer<SendPort>();
    rcvPort.listen((message) {
      if (message is SendPort) completer.complete(message);

      print(message);

      if (message is! SendPort) {
        rcvPort.close();
        isolate.kill();
      }
    });

    final send2Isolate = await completer.future;
    send2Isolate.send(1000000000);
  }
}

void doSomething(var bigNumber) {
  final timer = Stopwatch()..start();
  print('Doing something');

  var sum = 0;
  for (var i = 0; i <= bigNumber; i++) {
    sum += i;
  }
  print('finished ${sum}');
  print('InitializeAppData Completed in ${timer.elapsedMilliseconds} ms');
  timer.stop();
}

void _doSomethingForSpawn(SendPort sendPort) {
  final rcvPort = ReceivePort();
  sendPort.send(rcvPort.sendPort);

  rcvPort.listen((bigNumber) {
    var sum = 0;
    for (var i = 0; i <= bigNumber; i++) {
      sum += i;
    }

    sendPort.send(sum);
  });
}
