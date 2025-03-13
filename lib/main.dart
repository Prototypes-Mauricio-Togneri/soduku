import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sudoku'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _parseImage,
        tooltip: 'Parse',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future _parseImage() async {
    final InputImage inputImage = InputImage.fromFilePath('example/sudoku.png');
    final TextRecognizer textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    final String text = recognizedText.text;
    print(text);

    for (final TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      print(rect);

      final List<Point<int>> cornerPoints = block.cornerPoints;
      print(cornerPoints);

      final String text = block.text;
      print(text);

      final List<String> languages = block.recognizedLanguages;
      print(languages);

      for (final TextLine line in block.lines) {
        for (final TextElement element in line.elements) {
          final String text = element.text;
          print(text);
        }
      }
    }
  }
}
