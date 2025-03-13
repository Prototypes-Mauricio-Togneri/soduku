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
      body: Center(child: Text(detectedText)),
      floatingActionButton: FloatingActionButton(
        onPressed: _parseImage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future _parseImage() async {
    final TextRecognizer textRecognizer = TextRecognizer();

    final String value = await _parseCell(
      textRecognizer: textRecognizer,
      rect: const Rect.fromLTWH(0, 0, 110, 110),
    );

    setState(() {
      detectedText = value;
    });
  }

  Future<String> _parseCell({
    required TextRecognizer textRecognizer,
    required Rect rect,
  }) async {
    final InputImage inputImage = await _inputImage(
      const Rect.fromLTWH(0, 0, 110, 110),
    );
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    return recognizedText.text;
  }

  Future _inputImage(Rect rect) async {
    final ByteData data = await rootBundle.load('assets/example/sudoku.png');
    final Image originalImage = decodeImage(data.buffer.asUint8List())!;
    final Image subImage = copyCrop(
      originalImage,
      rect.left.toInt(),
      rect.top.toInt(),
      rect.width.toInt(),
      rect.height.toInt(),
    );

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
