import 'package:sudoku_solver/model/grid.dart';

class Solver {
  final Grid grid;

  const Solver({required this.grid});
}

void main(List<String> args) {
  final Grid grid = Grid.random();
  print(grid);
}
