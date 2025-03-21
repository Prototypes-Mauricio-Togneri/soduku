import 'dart:io';
import 'dart:math';

typedef Row = List<int>;
typedef Column = List<int>;
typedef Quadrant = List<int>;

class Grid {
  final List<Row> _rows;

  const Grid({required List<List<int>> rows}) : _rows = rows;

  List<Column> get _columns => [
    _column(0),
    _column(1),
    _column(2),
    _column(3),
    _column(4),
    _column(5),
    _column(6),
    _column(7),
    _column(8),
  ];

  List<Quadrant> get _quadrants => [
    _quadrant(0, 0),
    _quadrant(0, 1),
    _quadrant(0, 2),
    _quadrant(1, 0),
    _quadrant(1, 1),
    _quadrant(1, 2),
    _quadrant(2, 0),
    _quadrant(2, 1),
    _quadrant(2, 2),
  ];

  bool get isSolved {
    for (final Row row in _rows) {
      if (row.contains(0) || _hasDuplicates(row)) {
        return false;
      }
    }

    for (final Column column in _columns) {
      if (column.contains(0) || _hasDuplicates(column)) {
        return false;
      }
    }

    for (final Quadrant quadrant in _quadrants) {
      if (quadrant.contains(0) || _hasDuplicates(quadrant)) {
        return false;
      }
    }

    return true;
  }

  bool get isUnsolvable {
    for (final Row row in _rows) {
      if (_hasDuplicates(row.where((e) => e != 0).toList())) {
        return true;
      }
    }

    for (final Column column in _columns) {
      if (_hasDuplicates(column.where((e) => e != 0).toList())) {
        return true;
      }
    }

    for (final Quadrant quadrant in _quadrants) {
      if (_hasDuplicates(quadrant.where((e) => e != 0).toList())) {
        return true;
      }
    }

    return false;
  }

  Grid _solveBacktracking() {
    final Grid? solution = _solveForRow(0);

    if (solution != null) {
      return solution;
    } else {
      throw UnsolvableSudoku();
    }
  }

  Grid _solveInferring() {
    final Grid grid = Grid(rows: _cloneRows());
    bool canInfer = true;

    while (canInfer) {
      canInfer = false;

      for (int row = 0; row < 9; row++) {
        for (int column = 0; column < 9; column++) {
          if (grid.get(row, column) == 0) {
            final List<int> values = grid._possibleValuesAt(row, column);

            if (values.length == 1) {
              grid.set(row, column, values.first);
              canInfer = true;
            }
          }
        }
      }
    }

    return grid;
  }

  Grid solve() {
    if (isUnsolvable) {
      throw UnsolvableSudoku();
    } else {
      final Grid solution = _solveInferring();

      return solution.isSolved ? solution : solution._solveBacktracking();
    }
  }

  Grid? _solveForRow(int index) {
    final List<Row> possibleRows = _possibleRows(index);

    for (final Row possibleRow in possibleRows) {
      final Grid grid = _withRow(possibleRow, index);

      if (index < 8) {
        final Grid? newGrid = grid._solveForRow(index + 1);

        if (newGrid != null) {
          return newGrid;
        }
      } else if (grid.isSolved) {
        return grid;
      }
    }

    return null;
  }

  Grid _withRow(Row row, int index) {
    final List<Row> newRows = _cloneRows();
    newRows[index] = row;

    return Grid(rows: newRows);
  }

  int get(int row, int column) => _rows[row][column];

  void set(int row, int column, int value) => _rows[row][column] = value;

  List<Row> _possibleRows(int index) {
    final List<Row> result = [];

    for (final int a in _possibleValuesAt(index, 0)) {
      for (final int b in _possibleValuesAt(index, 1)) {
        for (final int c in _possibleValuesAt(index, 2)) {
          for (final int d in _possibleValuesAt(index, 3)) {
            for (final int e in _possibleValuesAt(index, 4)) {
              for (final int f in _possibleValuesAt(index, 5)) {
                for (final int g in _possibleValuesAt(index, 6)) {
                  for (final int h in _possibleValuesAt(index, 7)) {
                    for (final int i in _possibleValuesAt(index, 8)) {
                      final Row row = [a, b, c, d, e, f, g, h, i];

                      if (!_hasDuplicates(row)) {
                        result.add([a, b, c, d, e, f, g, h, i]);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return result;
  }

  bool _hasDuplicates(Row values) {
    final Set<int> uniqueValues = values.toSet();

    return uniqueValues.length != values.length;
  }

  List<int> _possibleValuesAt(int row, int column) {
    final int value = get(row, column);

    if (value == 0) {
      final Set<int> invalidValues = {
        ..._rows[row],
        ..._column(column),
        ..._quadrant(row, column),
      };
      final List<int> result = [];

      for (int i = 1; i <= 9; i++) {
        if (!invalidValues.contains(i)) {
          result.add(i);
        }
      }

      return result;
    } else {
      return [value];
    }
  }

  Column _column(int index) => [
    _rows[0][index],
    _rows[1][index],
    _rows[2][index],
    _rows[3][index],
    _rows[4][index],
    _rows[5][index],
    _rows[6][index],
    _rows[7][index],
    _rows[8][index],
  ];

  Quadrant _quadrant(int row, int column) {
    final int quadrantRow = row ~/ 3;
    final int quadrantColumn = column ~/ 3;
    final Quadrant result = [];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final int value = get(quadrantRow * 3 + i, quadrantColumn * 3 + j);
        result.add(value);
      }
    }

    return result;
  }

  factory Grid.fromString(String input) {
    final List<String> lines = input.split('\n');
    final List<Row> rows = [];

    for (final String line in lines) {
      final List<int> row = line.trim().split(' ').map(int.parse).toList();
      rows.add(row);
    }

    return Grid(rows: rows);
  }

  factory Grid.fromFile(String filePath) {
    final String input = File(filePath).readAsStringSync();

    return Grid.fromString(input);
  }

  factory Grid.random() {
    final List<Row> rows = [];
    final Random random = Random();

    for (int i = 0; i < 9; i++) {
      final List<int> row = [
        random.nextInt(10),
        random.nextInt(10),
        random.nextInt(10),
        random.nextInt(10),
        random.nextInt(10),
        random.nextInt(10),
        random.nextInt(10),
        random.nextInt(10),
        random.nextInt(10),
      ];
      rows.add(row);
    }

    return Grid(rows: rows);
  }

  @override
  String toString() {
    String result = '';

    result += '┌───────┬───────┬───────┐\n';
    result += _printRow(_rows[0]);
    result += _printRow(_rows[1]);
    result += _printRow(_rows[2]);
    result += '├───────┼───────┼───────┤\n';
    result += _printRow(_rows[3]);
    result += _printRow(_rows[4]);
    result += _printRow(_rows[5]);
    result += '├───────┼───────┼───────┤\n';
    result += _printRow(_rows[6]);
    result += _printRow(_rows[7]);
    result += _printRow(_rows[8]);
    result += '└───────┴───────┴───────┘\n';

    return result;
  }

  String _printRow(Row row) {
    final String column1 =
        '${_printCell(row[0])} ${_printCell(row[1])} ${_printCell(row[2])}';
    final String column2 =
        '${_printCell(row[3])} ${_printCell(row[4])} ${_printCell(row[5])}';
    final String column3 =
        '${_printCell(row[6])} ${_printCell(row[7])} ${_printCell(row[8])}';

    return '│ $column1 │ $column2 │ $column3 │\n';
  }

  String _printCell(int value) => value == 0 ? '_' : value.toString();

  List<Row> _cloneRows() {
    final List<Row> result = [];

    for (final Row row in _rows) {
      result.add(List.of(row));
    }

    return result;
  }
}

class UnsolvableSudoku implements Exception {
  final String message;

  UnsolvableSudoku([this.message = 'The Sudoku puzzle is unsolvable.']);

  @override
  String toString() => message;
}

void main(List<String> args) {
  /*const String data = '''
    5 3 0 0 7 0 0 0 0
    6 0 0 1 9 5 0 0 0
    0 9 8 0 0 0 0 6 0
    8 0 0 0 6 0 0 0 3
    4 0 0 8 0 3 0 0 1
    7 0 0 0 2 0 0 0 6
    0 6 0 0 0 0 2 8 0
    0 0 0 4 1 9 0 0 5
    0 0 0 0 8 0 0 7 9
  ''';*/
  const String data = '''
    0 2 0 6 0 8 0 0 0
    5 8 0 0 0 9 7 0 0
    0 0 0 0 4 0 0 0 0
    3 7 0 0 0 0 5 0 0
    6 0 0 0 0 0 0 0 4
    0 0 8 0 0 0 0 1 3
    0 0 0 0 2 0 0 0 0
    0 0 9 8 0 0 0 3 6
    0 0 0 3 0 6 0 9 0
  ''';
  final Grid original = Grid.fromString(data.trim());
  final int now = DateTime.now().millisecondsSinceEpoch;
  final Grid solution = original.solve();
  final int then = DateTime.now().millisecondsSinceEpoch;

  print(solution);
  print('Elapsed time: ${then - now} ms');
}
