import 'dart:async';
import 'dart:isolate';

void main() => Future<void>(() async {
      final isolate = await IsolateController.spawn<int>(
        (payload) {
          for (var i = 1, r = 1; i <= payload; i++, r *= i) {
            // Send a message to the main isolate.
            print('$i! = $r');
          }
        },
        7,
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      isolate.close(); // Close our isolate.
    });

/// A handler for the messages in the isolate.
typedef IsolateHandler<Payload> = FutureOr<void> Function(
  Payload payload,
);

/// A wrapper around an isolate.
class IsolateController {
  IsolateController._({
    required this.close,
  });

  /// Entry point of the isolate.
  static Future<void> _$entryPoint<Payload>(_IsolateArgument<Payload> argument) async {
    // Call the handler with the payload.
    await argument();
  }

  /// Spawns a new isolate and sends it a message.
  static Future<IsolateController> spawn<Payload>(
    IsolateHandler<Payload> handler,
    Payload payload,
  ) async {
    // Create a argument for the isolate.
    final argument = _IsolateArgument<Payload>(
      handler: handler,
      payload: payload,
    );

    // Spawn a new isolate.
    final isolate = await Isolate.spawn<_IsolateArgument<Payload>>(
      _$entryPoint<Payload>,
      argument,
      errorsAreFatal: true,
      debugName: 'MyIsolate',
    );

    // Close the isolate, should be called when the isolate is no longer needed.
    void close() {
      isolate.kill();
    }

    // Return a new instance of [MyIsolate].
    return IsolateController._(
      close: close,
    );
  }

  /// Close the isolate.
  final void Function() close;
}

/// Payload of the initial message sent to the isolate.
class _IsolateArgument<Payload> {
  _IsolateArgument({
    required this.handler,
    required this.payload,
  });

  /// Handler for the messages.
  final IsolateHandler<Payload> handler;

  /// Initial message of the isolate.
  final Payload payload;

  /// Call the handler with the payload.
  FutureOr<void> call() => handler(payload);
}
