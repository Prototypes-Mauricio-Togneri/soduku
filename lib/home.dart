import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart';
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
      final Image image = await _getImage();
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

  Future<Image> _getImage() async {
    final ByteData data = await rootBundle.load('assets/example/sudoku.png');

    return decodeImage(data.buffer.asUint8List())!;
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
    return const Padding(
      padding: EdgeInsets.all(36),
      child: AspectRatio(aspectRatio: 1, child: Placeholder()),
    );
  }
}

enum HomeState { initial, processing, result }

class Operation {
  final Image inputImage;
  final Grid inputGrid;
  final Grid outputGrid;

  const Operation({
    required this.inputImage,
    required this.inputGrid,
    required this.outputGrid,
  });
}
