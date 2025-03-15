import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image/image.dart' as img;
import 'package:sudoku_solver/grid.dart' hide Column;
import 'package:sudoku_solver/scanner.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Operation? operation;
  HomeState state = HomeState.initial;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(body: body),
    );
  }

  Widget get body {
    if (state == HomeState.initial) {
      return Initial(_onScan);
    } else if (state == HomeState.processing) {
      return const Processing();
    } else {
      return Result(operation: operation!, onScan: _onScan);
    }
  }

  Future _onScan() async {
    setState(() {
      state = HomeState.processing;
    });

    try {
      final img.Image image = await _getImage();
      final Grid inputGrid = await Scanner().scan(image);
      final Grid outputGrid = inputGrid.solve();

      operation = Operation(
        inputImage: image,
        inputGrid: inputGrid,
        outputGrid: outputGrid,
      );

      setState(() {
        state = HomeState.result;
      });
    } catch (e) {
      if (!(e is PlatformException)) {
        _showError('The Sudoku could not be solved.');
      }

      setState(() {
        state = HomeState.initial;
      });
    }
  }

  Future<img.Image> _getImage() async {
    final DocumentScannerOptions options = DocumentScannerOptions(
      documentFormat: DocumentFormat.jpeg,
      mode: ScannerMode.full,
      pageLimit: 1,
      isGalleryImport: true,
    );
    final DocumentScanner scanner = DocumentScanner(options: options);

    try {
      final DocumentScanningResult result = await scanner.scanDocument();
      final List<String> images = result.images;

      if (images.isNotEmpty) {
        final File file = File(images.first);
        return img.decodeImage(file.readAsBytesSync())!;
      } else {
        throw Exception();
      }
    } finally {
      await scanner.close();
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Initial extends StatelessWidget {
  final VoidCallback onScan;

  const Initial(this.onScan);

  @override
  Widget build(BuildContext context) {
    return Center(child: ScanButton(onScan));
  }
}

class ScanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScanButton(this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text('SCAN'),
    );
  }
}

class Processing extends StatelessWidget {
  const Processing();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class Result extends StatelessWidget {
  final Operation operation;
  final VoidCallback onScan;

  const Result({required this.operation, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [ResultGrid(operation), ScanButton(onScan)],
      ),
    );
  }
}

class ResultGrid extends StatelessWidget {
  final Operation operation;

  const ResultGrid(this.operation);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Image.memory(
              Uint8List.fromList(img.encodePng(operation.inputImage)),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  painter: SolutionPainter(operation),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SolutionPainter extends CustomPainter {
  final Operation operation;

  const SolutionPainter(this.operation);

  @override
  void paint(Canvas canvas, Size size) {
    final double fontSize = size.width / 11;

    final Grid inputGrid = operation.inputGrid;
    final Grid outputGrid = operation.outputGrid;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        final int valueInput = inputGrid.get(j, i);
        final int valueOutput = outputGrid.get(j, i);

        if (valueOutput != valueInput) {
          _drawValue(
            value: valueOutput,
            i: i,
            j: j,
            fontSize: fontSize,
            canvas: canvas,
            size: size,
          );
        }
      }
    }
  }

  void _drawValue({
    required int value,
    required int i,
    required int j,
    required double fontSize,
    required Canvas canvas,
    required Size size,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: TextStyle(
          color: Colors.red,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    final double x = (i * (size.width / 9)) + (textPainter.width / 2);
    final double y = j * (size.height / 9);

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum HomeState { initial, processing, result }

class Operation {
  final img.Image inputImage;
  final Grid inputGrid;
  final Grid outputGrid;

  const Operation({
    required this.inputImage,
    required this.inputGrid,
    required this.outputGrid,
  });
}
