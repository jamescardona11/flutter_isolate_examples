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

    final rp = receivePort.asBroadcastStream();
    send2Isolate = await rp.first;

    initSubscriptions(rp);
  }

  void initSubscriptions(Stream<dynamic> receivePort) {
    subscription = receivePort //
        .takeWhile((element) => element is String)
        .cast<String>()
        .listen((message) {
      encodedData.add(message);
      setState(() {});
    });
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

  final messages = rp.takeWhile((element) => element is int).cast<int>();

  await for (final message in messages) {
    final r = generateRandomString(message);
    sendPort.send(r);
  }
}
