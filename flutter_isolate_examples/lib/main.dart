import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/demo/demo_image_processing_page.dart';
import 'package:flutter_isolate_examples/learning_1/learning_1.dart';

import 'learning_2/bidirectional_example.dart';
import 'learning_2/spawn_example.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _navigateToExample1(context, const Learning1()),
                child: const Text('W-W-H'),
              ),
              Divider(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _navigateToExample1(context, const SpawnExample()),
                child: const Text('Spawn'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _navigateToExample1(context, const BidirectionalExample()),
                child: const Text('Spawn bi-directional'),
              ),
              Divider(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _navigateToExample1(context, const DemoImageProcessingPage()),
                child: const Text('Demo Compress'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text('Demo Upload'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text('Demo JSON'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToExample1(BuildContext context, Widget example) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => example,
      ),
    );
  }
}
