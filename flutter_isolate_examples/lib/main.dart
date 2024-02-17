import 'package:flutter/material.dart';
import 'package:flutter_isolate_examples/learning_1/learning_1.dart';

void main() {
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
                child: const Text('Example 1'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text('Example 2'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text('Example 3'),
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
