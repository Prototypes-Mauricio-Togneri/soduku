import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      _showError();

      setState(() {
        state = HomeState.initial;
      });
    }
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('The Sudoku could not be solved.'),
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

  Future<img.Image> _getImage() async {
    final ByteData data = await rootBundle.load('assets/example/sudoku.png');

    return img.decodeImage(data.buffer.asUint8List())!;
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

    _drawValue(
      value: 5,
      x: 0,
      y: 0,
      fontSize: fontSize,
      canvas: canvas,
      size: size,
    );
  }

  void _drawValue({
    required int value,
    required int x,
    required int y,
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

    final Offset offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
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
