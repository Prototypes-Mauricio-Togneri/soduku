import 'package:sudoku_solver/model/grid.dart';
import 'package:test/test.dart';

void main() {
  group('Group example', () {
    test('Test 1', () {
      final Grid grid = Grid.fromFile('./test/resources/example1.txt');
      expect(grid.rows.length, 9);
    });
  });
}
