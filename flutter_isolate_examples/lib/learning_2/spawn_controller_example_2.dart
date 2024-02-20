import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import 'utils/random_helper.dart';

class SpawnControllerExample2 extends StatefulWidget {
  const SpawnControllerExample2({
    Key? key,
  }) : super(key: key);

  @override
  State<SpawnControllerExample2> createState() => _SpawnControllerExample2State();
}

class _SpawnControllerExample2State extends State<SpawnControllerExample2> {
  List<String> encodedData = [];
  int? lastRandomNumber;

  StreamSubscription? subscription;
  IsolateController<IsolateMessage, String>? isolateController;

  @override
  void initState() {
    super.initState();
    createIsolate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spawn Controller Example 2'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    lastRandomNumber = generateRandomNumber();
                    setState(() {});

                    isolateController?.send(IsolateMessageData(lastRandomNumber!));
                  },
                  child: const Text('Random number'),
                ),
                TextButton(
                  onPressed: () async {
                    isolateController?.send(IsolateMessageClose());
                  },
                  child: const Text('Close'),
                ),
              ],
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
    subscription = isolateController?.broadcastRp.listen((message) {
      encodedData.add(message);
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    isolateController?.dispose();
    super.dispose();
  }
}

class IsolateController<I, O> {
  final SendPort _commands;
  final ReceivePort _responses;

  final StreamController<O> _controller = StreamController<O>.broadcast();
  late final StreamSubscription<O> _subscription;

  IsolateController._({
    required ReceivePort receivePort,
    required SendPort sendPort,
    required Stream<dynamic> output,
  })  : _responses = receivePort,
        _commands = sendPort {
    _subscription = output //
        .takeWhile((element) => element is O)
        .cast<O>()
        .listen((event) {
      _controller.add(event);
    });
  }

  static Future<IsolateController<I, O>?> create<I, O>() async {
    final initPort = ReceivePort();

    try {
      await Isolate.spawn(
        _entryPoint,
        initPort.sendPort,
      );

      final broadcastRp = initPort.asBroadcastStream();
      final sendPort = await broadcastRp.first;

      return IsolateController._(
        receivePort: initPort,
        output: broadcastRp,
        sendPort: sendPort,
      );
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
  final int data;

  IsolateMessageData(this.data);
}

class IsolateMessageClose extends IsolateMessage {}

void _entryPoint(SendPort sendPort) async {
  final rp = ReceivePort();
  sendPort.send(rp.sendPort);

  final messages = rp.takeWhile((element) => element is IsolateMessage).cast<IsolateMessage>();

  await for (final message in messages) {
    switch (message) {
      case IsolateMessageData _:
        final r = generateRandomString(message.data);
        sendPort.send(r);
        break;
      case IsolateMessageClose _:
        Isolate.exit(sendPort, 'closed');
    }
  }
}
