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
  final double CELL_SIZE = 113.777777778;

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

    final TextRecognizer textRecognizer = TextRecognizer();
    final List<String> row1 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 0,
    );
    final List<String> row2 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 1,
    );
    final List<String> row3 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 2,
    );
    final List<String> row4 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 3,
    );
    final List<String> row5 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 4,
    );
    final List<String> row6 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 5,
    );
    final List<String> row7 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 6,
    );
    final List<String> row8 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 7,
    );
    final List<String> row9 = await _parseRow(
      textRecognizer: textRecognizer,
      y: 8,
    );

    setState(() {
      detectedText =
          '$row1\n$row2\n$row3\n$row4\n$row5\n$row6\n$row7\n$row8\n$row9';
    });
  }

  Future<List<String>> _parseRow({
    required TextRecognizer textRecognizer,
    required int y,
  }) async {
    final List<String> result = [];

    for (int i = 0; i < 9; i++) {
      final String value = await _parseCell(
        textRecognizer: textRecognizer,
        rect: Rect.fromLTWH(i * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE),
      );
      result.add(value.isEmpty ? '0' : value);
    }

    return result;
  }

  Future<String> _parseCell({
    required TextRecognizer textRecognizer,
    required Rect rect,
  }) async {
    final InputImage inputImage = await _inputImage(rect);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    final String result = recognizedText.text.trim();

    return result.isEmpty ? '' : result.substring(0, 1);
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
