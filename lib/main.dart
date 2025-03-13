import 'dart:io';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

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
    final InputImage inputImage = await _inputImage();
    final TextRecognizer textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    final String text = recognizedText.text;
    print(text);

    for (final TextBlock block in recognizedText.blocks) {
      final String text = block.text;
      print(text);

      for (final TextLine line in block.lines) {
        for (final TextElement element in line.elements) {
          final String text = element.text;
          print(text);
        }
      }
    }
  }

  Future _inputImage() async {
    final ByteData data = await rootBundle.load('assets/example/sudoku.png');
    final Image originalImage = decodeImage(data.buffer.asUint8List())!;
    final Image subImage = copyCrop(originalImage, 0, 0, 110, 110);

    //final Directory directory = await getTemporaryDirectory();
    final Directory? directory = await getDownloadsDirectory();
    final File file = File('${directory?.path}/sub_image.png');
    await file.writeAsBytes(encodePng(subImage));

    return InputImage.fromFile(file);
  }

  Future<InputImage> inputImage2() async {
    final ByteData buffer = await rootBundle.load('assets/example/sudoku.png');
    final Directory? directory = await getDownloadsDirectory();
    final File file = File('${directory?.path}/sudoku.png');
    await file.writeAsBytes(buffer.buffer.asUint8List());

    return InputImage.fromFile(file);
  }
}
