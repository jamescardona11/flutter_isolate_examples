import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import 'utils/random_helper.dart';

class SpawnControllerExample extends StatefulWidget {
  const SpawnControllerExample({
    Key? key,
  }) : super(key: key);

  @override
  State<SpawnControllerExample> createState() => _SpawnControllerExampleState();
}

class _SpawnControllerExampleState extends State<SpawnControllerExample> {
  List<String> encodedData = [];
  int? lastRandomNumber;

  StreamSubscription? subscription;
  IsolateController<int>? isolateController;

  @override
  void initState() {
    super.initState();
    createIsolate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                lastRandomNumber = generateRandomNumber();
                setState(() {});

                isolateController?.send(lastRandomNumber!);
              },
              child: const Text('Random number'),
            ),
            const SizedBox(height: 20),
            if (lastRandomNumber != null) Text('Last random number: $lastRandomNumber'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: encodedData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(encodedData[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createIsolate() async {
    isolateController = await IsolateController.create();
    subscription = isolateController?._broadcastRp.listen((message) {
      encodedData.add(message);
      setState(() {});
    });
  }

  @override
  void dispose() {
    isolateController?.close();
    subscription?.cancel();
    super.dispose();
  }
}

class IsolateController<T> {
  final Isolate _isolate;
  final ReceivePort _receivePort;
  final Stream<dynamic> _broadcastRp;
  final SendPort _sendPort;

  IsolateController._({
    required Isolate isolate,
    required ReceivePort receivePort,
    required Stream<dynamic> broadcastRp,
    required SendPort sendPort,
  })  : _isolate = isolate,
        _receivePort = receivePort,
        _broadcastRp = broadcastRp,
        _sendPort = sendPort;

  static Future<IsolateController<T>> create<T>() async {
    final receivePort = ReceivePort();

    final isolate = await Isolate.spawn(
      _entryPoint,
      receivePort.sendPort,
      errorsAreFatal: true,
      onExit: receivePort.sendPort,
      onError: receivePort.sendPort,
    );

    final broadcastRp = receivePort.asBroadcastStream();
    final send2Isolate = await broadcastRp.first;

    return IsolateController._(
      isolate: isolate,
      receivePort: receivePort,
      broadcastRp: broadcastRp,
      sendPort: send2Isolate,
    );
  }

  void send(T message) {
    _sendPort.send(message);
  }

  void close() {
    _isolate.kill();
    _receivePort.close();
  }

  Stream<String> watchMessages(String forGreeting) {
    return _broadcastRp //
        .takeWhile((element) => element is String)
        .cast<String>();
  }
}

void _entryPoint(SendPort sendPort) async {
  final rp = ReceivePort();
  sendPort.send(rp.sendPort);

  final messages = rp.takeWhile((element) => element is int).cast<int>();

  await for (final message in messages) {
    final r = generateRandomString(message);
    sendPort.send(r);
  }
}
