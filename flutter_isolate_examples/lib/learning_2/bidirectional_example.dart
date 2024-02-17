import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/learning_2/utils/random_helper.dart';

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

  @override
  void initState() {
    super.initState();
    subscription = _getEncodedStream().take(10).listen((event) {
      encodedData.add(event);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              lastRandomNumber = generateRandomNumber();
              setState(() {});
            },
            child: const Text('Random number'),
          ),
          const SizedBox(height: 20),
          if (lastRandomNumber != null) Text('Last random number: $lastRandomNumber'),
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

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Stream<String> _getEncodedStream() {
    final receivePort = ReceivePort();
    return Isolate.spawn(_entryPoint, receivePort.sendPort)
        .asStream()
        .asyncExpand((i) => receivePort)
        .takeWhile((element) => element is String)
        .cast();
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
