import 'package:flutter/material.dart';
import 'package:sudoku_solver/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sudoku Solver',
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
