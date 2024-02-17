import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import 'utils/random_helper.dart';

class SpawnExample extends StatefulWidget {
  const SpawnExample({
    Key? key,
  }) : super(key: key);

  @override
  State<SpawnExample> createState() => _SpawnExampleState();
}

class _SpawnExampleState extends State<SpawnExample> {
  List<String> encodedData = [];
  int? lastRandomNumber;

  StreamSubscription? subscription;
  Isolate? isolate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              encodedData.clear();
              setState(() {});
              subscription?.cancel();

              isolate?.kill();

              final receivePort = ReceivePort();
              isolate = await Isolate.spawn(_entryPoint, receivePort.sendPort);

              initSubscriptions(receivePort);
            },
            child: const Text('Start'),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: encodedData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(encodedData[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  void initSubscriptions(ReceivePort receivePort) {
    subscription = receivePort //
        .takeWhile((element) => element is String)
        .take(10)
        .listen((event) {
      encodedData.add(event);
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
  await for (final now in Stream.periodic(
    Duration(milliseconds: 200),
    (_) {
      final randomNumber = generateRandomNumber();
      return generateRandomString(randomNumber);
    },
  )) {
    sendPort.send(now);
  }
}
