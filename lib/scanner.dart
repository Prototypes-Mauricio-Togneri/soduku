import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

class Scanner {
  Future<String> scan() async {
    final ByteData data = await rootBundle.load('assets/example/sudoku.png');
    final Image image = decodeImage(data.buffer.asUint8List())!;
    final TextRecognizer textRecognizer = TextRecognizer();
    final double cellSize = _cellSize(image);

    final List<String> row1 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 0,
    );
    final List<String> row2 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 1,
    );
    final List<String> row3 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 2,
    );
    final List<String> row4 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 3,
    );
    final List<String> row5 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 4,
    );
    final List<String> row6 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 5,
    );
    final List<String> row7 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 6,
    );
    final List<String> row8 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 7,
    );
    final List<String> row9 = await _parseRow(
      textRecognizer: textRecognizer,
      image: image,
      cellSize: cellSize,
      rowIndex: 8,
    );

    return '$row1\n$row2\n$row3\n$row4\n$row5\n$row6\n$row7\n$row8\n$row9';
  }

  double _cellSize(Image image) {
    final int imageWidth = image.width;
    final int imageHeight = image.height;

    return max(imageWidth, imageHeight) / 9;
  }

  Future<List<String>> _parseRow({
    required TextRecognizer textRecognizer,
    required Image image,
    required double cellSize,
    required int rowIndex,
  }) async {
    final List<String> result = [];

    for (int i = 0; i < 9; i++) {
      final String value = await _parseCell(
        textRecognizer: textRecognizer,
        image: image,
        rect: Rect.fromLTWH(
          i * cellSize,
          rowIndex * cellSize,
          cellSize,
          cellSize,
        ),
      );
      result.add(value.isEmpty ? '0' : value);
    }

    return result;
  }

  Future<String> _parseCell({
    required TextRecognizer textRecognizer,
    required Image image,
    required Rect rect,
  }) async {
    final InputImage inputImage = await _inputImage(image: image, rect: rect);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    final String result = recognizedText.text.trim();

    return result.isEmpty ? '' : result.substring(0, 1);
  }

  Future _inputImage({required Image image, required Rect rect}) async {
    final Image subImage = copyCrop(
      image,
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

  Future<InputImage> inputImageCleaned() async {
    final ByteData buffer = await rootBundle.load('assets/example/cleaned.png');
    final Directory? directory = await getDownloadsDirectory();
    final File file = File('${directory?.path}/sudoku.png');
    await file.writeAsBytes(buffer.buffer.asUint8List());

    return InputImage.fromFile(file);
  }
}
