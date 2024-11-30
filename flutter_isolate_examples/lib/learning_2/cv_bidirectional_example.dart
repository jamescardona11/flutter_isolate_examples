import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/learning_2/utils/random_helper.dart';

class CVBidirectionalExample extends StatefulWidget {
  const CVBidirectionalExample({
    Key? key,
  }) : super(key: key);

  @override
  State<CVBidirectionalExample> createState() => _CVBidirectionalExampleState();
}

class _CVBidirectionalExampleState extends State<CVBidirectionalExample> {
  List<String> encodedData = [];
  int? lastRandomNumber;

  StreamSubscription? subscription;

  SendPort? _sendPort;
  Isolate? isolate;

  @override
  void initState() {
    super.initState();
    createIsolate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bidirectional Example'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                lastRandomNumber = generateRandomNumber();
                setState(() {});

                final message = await resultAsync(lastRandomNumber ?? 0);
                encodedData.add(message);
                setState(() {});
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

  static late ReceivePort _receivePort;

  void createIsolate() async {
    _receivePort = ReceivePort();
    isolate = await Isolate.spawn(_entryPoint, _receivePort.sendPort);

    final broadcastRp = _receivePort.asBroadcastStream();
    _sendPort = await broadcastRp.first;

    // initSubscriptions(broadcastRp);
  }

  Future<String> resultAsync(int randomNumber) async {
    // final responsePort = ReceivePort();
    _sendPort!.send(randomNumber);
    final response = await _receivePort.asBroadcastStream().first;
    return response as String;
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
  final post = ReceivePort();
  sendPort.send(post.sendPort);

  // final messages = rp.takeWhile((element) => element is int).cast<int>();

  // await for (final message in messages) {
  //   final r = generateRandomString(message);
  //   sendPort.send(r);
  // }

  post.listen((message) {
    // final records = message[0] as int;
    // final sendPort = message[1] as SendPort;
    final result = generateRandomString(message);
    sendPort.send(result);
  });
}
