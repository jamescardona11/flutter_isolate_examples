import 'package:flutter/material.dart';

import 'animation.dart';
import 'isolates_service.dart';

class Learning1 extends StatefulWidget {
  const Learning1({
    super.key,
  });

  @override
  State<Learning1> createState() => _Learning1State();
}

class _Learning1State extends State<Learning1> {
  final IsolatesService _isolatesService = IsolatesService();
  var bigNumber = 1000000000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => _isolatesService.doSomething(bigNumber),
              child: const Text('Do something'),
            ),
            TextButton(
              onPressed: _isolatesService.computeIsolate,
              child: const Text('Compute'),
            ),
            TextButton(
              onPressed: _isolatesService.spawn,
              child: const Text('Spawn'),
            ),
            const SizedBox(height: 20),
            const BouncingBallAnimation(),
          ],
        ),
      ),
    );
  }
}
