import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sudoku_solver/grid.dart';

class Scanner {
  Future<Grid> scan({
    required ScanProvider provider,
    required Image image,
  }) async {
    final double cellSize = _cellSize(image);
    final List<Row> rows = [];

    for (int i = 0; i < 9; i++) {
      final Row row = await _parseRow(
        provider: provider,
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
    required ScanProvider provider,
    required Image image,
    required double cellSize,
    required int rowIndex,
  }) async {
    final Row result = [];

    for (int i = 0; i < 9; i++) {
      final int value = await _parseCell(
        provider: provider,
        image: image,
        cellSize: cellSize,
        rowIndex: rowIndex,
        columnIndex: i,
      );
      result.add(value);
    }

    return result;
  }

  // TODO(momo): Review
  // https://github.com/darusc/Android-Sudoku-Solver-OCR
  // https://pub.dev/packages/edge_detection
  Future<int> _parseCell({
    required ScanProvider provider,
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
    final File cellImage = await _cellImage(image: image, rect: rect);
    final String result =
        provider == ScanProvider.tesseract
            ? await _scanWithTesseract(cellImage)
            : await _scanWithMLKit(
              file: cellImage,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
            );

    return _parseValue(result.trim());
  }

  Future<String> _scanWithTesseract(File file) =>
      FlutterTesseractOcr.extractText(
        file.path,
        language: 'eng',
        args: {'psm': '10'}, // Treat the image as a single character
      );

  Future<String> _scanWithMLKit({
    required File file,
    required int rowIndex,
    required int columnIndex,
  }) async {
    String result = '';
    final TextRecognizer textRecognizer = TextRecognizer();
    final RecognizedText recognisedText = await textRecognizer.processImage(
      InputImage.fromFilePath(file.path),
    );
    recognisedText.blocks.forEach((block) {
      block.lines.forEach((line) {
        line.elements.forEach((element) {
          element.symbols.forEach((originalSymbol) {
            final TextSymbol symbol = _sanitizeSymbol(originalSymbol);
            final double angle = symbol.angle ?? 0;
            final String value = symbol.text;

            if ((angle.abs() <= 20) && (value != result)) {
              result += value;
              print(
                'VALUE: [$rowIndex, $columnIndex]: ${symbol.text} ${symbol.angle} ${symbol.confidence} (YES)',
              );
            } else {
              print(
                'VALUE: [$rowIndex, $columnIndex]: ${symbol.text} ${symbol.angle} ${symbol.confidence} (NO)',
              );
            }
          });
        });
      });
    });

    return result;
  }

  TextSymbol _sanitizeSymbol(TextSymbol symbol) {
    final double angle = symbol.angle ?? 0;
    final String value = symbol.text;
    final bool isUpsideDown = (180 - angle.abs()).abs() <= 10;

    if (isUpsideDown) {
      if (value == '6') {
        return TextSymbol(
          text: '9',
          boundingBox: symbol.boundingBox,
          recognizedLanguages: symbol.recognizedLanguages,
          cornerPoints: symbol.cornerPoints,
          confidence: symbol.confidence,
          angle: 0,
        );
      } else if (value == '9') {
        return TextSymbol(
          text: '6',
          boundingBox: symbol.boundingBox,
          recognizedLanguages: symbol.recognizedLanguages,
          cornerPoints: symbol.cornerPoints,
          confidence: symbol.confidence,
          angle: 0,
        );
      }
    }

    return symbol;
  }

  int _parseValue(String value) {
    if (value.isNotEmpty) {
      try {
        final int result = int.parse(value);

        return (result > 0) && (result < 10) ? result : 0;
      } catch (e) {
        return 0;
      }
    } else {
      return 0;
    }
  }

  Future<File> _cellImage({required Image image, required Rect rect}) async {
    final Image subImage = copyCrop(
      image,
      rect.left.toInt(),
      rect.top.toInt(),
      rect.width.toInt(),
      rect.height.toInt(),
    );

    return _saveImage(subImage: subImage, name: 'sub_image');
  }

  Future<File> _saveImage({
    required Image subImage,
    required String name,
  }) async {
    final Directory directory = await getTemporaryDirectory();
    //final Directory? directory = await getDownloadsDirectory();
    final File file = File('${directory.path}/$name.png');
    await file.writeAsBytes(encodePng(subImage));

    return file;
  }
}

enum ScanProvider { tesseract, mlkit }
