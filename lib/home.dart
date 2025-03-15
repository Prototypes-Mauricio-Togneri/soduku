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
  Grid? result;
  HomeState state = HomeState.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          state == HomeState.initial
              ? Initial(_onScan)
              : state == HomeState.processing
              ? const Processing()
              : Result(grid: result!, onScan: _onScan),
    );
  }

  Future _onScan() async {
    setState(() {
      state = HomeState.processing;
    });

    final Image image = await _getImage();
    result = await Scanner().scan(image);

    setState(() {
      state = HomeState.result;
    });
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
  final Grid grid;
  final VoidCallback onScan;

  const Result({required this.grid, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [ResultGrid(grid), ScanButton(onScan)],
      ),
    );
  }
}

class ResultGrid extends StatelessWidget {
  final Grid grid;

  const ResultGrid(this.grid);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(36),
      child: AspectRatio(aspectRatio: 1, child: Placeholder()),
    );
  }
}

enum HomeState { initial, processing, result }
