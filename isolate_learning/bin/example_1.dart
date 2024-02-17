import 'dart:isolate';

void main(List<String> args) {
  getMessages().take(10).listen((event) {
    print(event);
  });
}

Stream<String> getMessages() {
  final receivePort = ReceivePort();
  return Isolate.spawn(_getMessages, receivePort.sendPort) //
      .asStream()
      .asyncExpand((i) => receivePort)
      .takeWhile((element) => element is String)
      .cast();
}

// Stream<String> getMessages2() async* {
//   final receivePort = ReceivePort();
//   await Isolate.spawn(_getMessages, receivePort.sendPort);

//   yield* receivePort //
//       .takeWhile((element) => element is String)
//       .cast();
// }

void _getMessages(SendPort sendPort) async {
  await for (final now in Stream.periodic(Duration(milliseconds: 200), (_) => DateTime.now().toIso8601String())) {
    sendPort.send(now);
  }
}
