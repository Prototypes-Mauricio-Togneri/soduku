import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sudoku_solver/grid.dart';

class Scanner {
  Future<Grid> scan(Image image) async {
    final double cellSize = _cellSize(image);
    final List<Row> rows = [];

    for (int i = 0; i < 9; i++) {
      final Row row = await _parseRow(
        image: image,
        cellSize: cellSize,
        rowIndex: i,
      );
      rows.add(row);
    }

    return Grid(rows: rows);
  }

  double _cellSize(Image image) {
    final int imageWidth = image.width;
    final int imageHeight = image.height;

    return max(imageWidth, imageHeight) / 9;
  }

  Future<Row> _parseRow({
    required Image image,
    required double cellSize,
    required int rowIndex,
  }) async {
    final Row result = [];

    for (int i = 0; i < 9; i++) {
      final int value = await _parseCell(
        image: image,
        cellSize: cellSize,
        rowIndex: rowIndex,
        columnIndex: i,
      );
      result.add(value);
    }

    return result;
  }

  Future<int> _parseCell({
    required Image image,
    required double cellSize,
    required int rowIndex,
    required int columnIndex,
  }) async {
    final double margin = cellSize * 0.1;
    final Rect rect = Rect.fromLTWH(
      (columnIndex * cellSize) + margin,
      (rowIndex * cellSize) + margin,
      cellSize - (margin * 2),
      cellSize - (margin * 2),
    );
    //final InputImage inputImage = await _inputImage(image: image, rect: rect);
    final File inputImage = await _inputImage(image: image, rect: rect);
    final String result = await _scanImage(image: inputImage);

    final Image subImage = copyCrop(
      image,
      rect.left.toInt(),
      rect.top.toInt(),
      rect.width.toInt(),
      rect.height.toInt(),
    );
    await _saveImage(
      subImage: subImage,
      name: '$rowIndex-$columnIndex-$result',
    );

    return result.isEmpty ? 0 : _parseValue(result);
  }

  Future<String> _scanImage({required File image}) async {
    final String text = await FlutterTesseractOcr.extractText(
      image.path,
      language: 'eng',
      args: {'psm': '10'}, // Treat the image as a single character
    );

    return text.trim();
  }

  /*Future<String> _scanImage2({
    required TextRecognizer textRecognizer,
    required InputImage image,
  }) async {
    final RecognizedText recognizedText = await textRecognizer.processImage(
      image,
    );

    return recognizedText.text.trim();
  }*/

  int _parseValue(String value) {
    try {
      final int result = int.parse(value);

      return (result > 0) && (result < 10) ? result : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<File> _inputImage({required Image image, required Rect rect}) async {
    final Image subImage = copyCrop(
      image,
      rect.left.toInt(),
      rect.top.toInt(),
      rect.width.toInt(),
      rect.height.toInt(),
    );

    return _saveImage(subImage: subImage, name: 'sub_image');
  }

  /*Future<InputImage> _inputImage2({
    required Image image,
    required Rect rect,
  }) async {
    final Image subImage = copyCrop(
      image,
      rect.left.toInt(),
      rect.top.toInt(),
      rect.width.toInt(),
      rect.height.toInt(),
    );
    final File file = await _saveImage(subImage: subImage, name: 'sub_image');

    return InputImage.fromFile(file);
  }*/

  Future<File> _saveImage({
    required Image subImage,
    required String name,
  }) async {
    //final Directory directory = await getTemporaryDirectory();
    final Directory? directory = await getDownloadsDirectory();
    final File file = File('${directory?.path}/$name.png');
    await file.writeAsBytes(encodePng(subImage));

    return file;
  }
}
