import 'package:flutter/material.dart';
import 'package:sudoku_solver/scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Flutter Demo', home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String detectedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            detectedText.isEmpty
                ? const CircularProgressIndicator()
                : Text(detectedText),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _parseImage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future _parseImage() async {
    setState(() {
      detectedText = '';
    });

    detectedText = await Scanner().scan();

    setState(() {});
  }
}
