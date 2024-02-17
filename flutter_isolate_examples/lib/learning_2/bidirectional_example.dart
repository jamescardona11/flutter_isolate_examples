import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/learning_2/utils/random_helper.dart';

class BidirectionalExample extends StatefulWidget {
  const BidirectionalExample({
    Key? key,
  }) : super(key: key);

  @override
  State<BidirectionalExample> createState() => _BidirectionalExampleState();
}

class _BidirectionalExampleState extends State<BidirectionalExample> {
  List<String> encodedData = [];
  int? lastRandomNumber;

  StreamSubscription? subscription;

  final completer = Completer<void>();
  SendPort? send2Isolate;
  Isolate? isolate;

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

                await completer.future;

                send2Isolate?.send(lastRandomNumber);
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
    final receivePort = ReceivePort();
    isolate = await Isolate.spawn(_entryPoint, receivePort.sendPort);
    initSubscriptions(receivePort);
  }

  void initSubscriptions(ReceivePort receivePort) {
    subscription = receivePort //
        .listen((message) {
      if (message is SendPort) {
        initSendPort(message);
        completer.complete();
      } else if (message is String) {
        encodedData.add(message);
        setState(() {});
      }
    });
  }

  void initSendPort(SendPort sendPort) {
    send2Isolate = sendPort;
  }

  @override
  void dispose() {
    isolate?.kill();
    subscription?.cancel();
    super.dispose();
  }
}

void _entryPoint(SendPort sendPort) async {
  final rp = ReceivePort();
  sendPort.send(rp.sendPort);

  rp.listen((number) {
    final r = generateRandomString(number);
    sendPort.send(r);
  });
}
