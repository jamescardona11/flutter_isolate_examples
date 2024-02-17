import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/demo/demo_image_processing_page.dart';
import 'package:flutter_isolate_examples/learning_1/learning_1.dart';

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
                child: const Text('Step 1 - W-W-H'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text('Example 2'),
              ),
              const SizedBox(height: 20),
              Divider(),
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
