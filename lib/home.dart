import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:sudoku_solver/grid.dart';
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
              : Result(result!),
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
    return Center(
      child: ElevatedButton(onPressed: onScan, child: const Text('SCAN')),
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

  const Result(this.grid);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        grid.toString(),
        style: const TextStyle(fontFamily: 'Monospace'),
      ),
    );
  }
}

enum HomeState { initial, processing, result }
