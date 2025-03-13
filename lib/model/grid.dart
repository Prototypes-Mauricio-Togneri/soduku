import 'dart:io';
import 'dart:math';

typedef Row = List<int>;
typedef Column = List<int>;

class Grid {
  final List<Row> rows;

  const Grid({required this.rows});

  // TODO(momo): implement
  bool get isSolved => false;

  Grid solve() => _solveForRow(0);

  Grid _solveForRow(int index) {
    final List<Row> possibleRows = _possibleRows(index);

    for (final Row possibleRow in possibleRows) {
      final Grid grid = _withRow(possibleRow, index);

      if (index < 8) {
        return grid._solveForRow(index + 1);
      } else if (grid.isSolved) {
        return grid;
      }
    }

    throw Exception('Unsolvable Sudoku');
  }

  Grid _withRow(Row row, int index) {
    final List<Row> rows = List.of(this.rows);
    rows[index] = row;

    return Grid(rows: rows);
  }

  int _get(int row, int column) => rows[row][column];

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
    final int value = _get(row, column);

    if (value == 0) {
      final Set<int> invalidValues = {
        ..._filterNonZero(rows[row]),
        ..._filterNonZero([
          rows[0][column],
          rows[1][column],
          rows[2][column],
          rows[3][column],
          rows[4][column],
          rows[5][column],
          rows[6][column],
          rows[7][column],
          rows[8][column],
        ]),
        ..._quadrantAt(row, column),
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

  List<int> _filterNonZero(List<int> input) =>
      input.where((e) => e != 0).toList();

  List<int> _quadrantAt(int row, int column) {
    final int quadrantRow = row ~/ 3;
    final int quadrantColumn = column ~/ 3;
    final List<int> result = [];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final int value = _get(quadrantRow * 3 + i, quadrantColumn * 3 + j);

        if (value != 0) {
          result.add(value);
        }
      }
    }

    return result;
  }

  factory Grid.fromString(String input) {
    final List<String> lines = input.split('\n');
    final List<Row> rows = [];

    for (final String line in lines) {
      final List<int> row = line.split(' ').map(int.parse).toList();
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
    result += _printRow(rows[0]);
    result += _printRow(rows[1]);
    result += _printRow(rows[2]);
    result += '├───────┼───────┼───────┤\n';
    result += _printRow(rows[3]);
    result += _printRow(rows[4]);
    result += _printRow(rows[5]);
    result += '├───────┼───────┼───────┤\n';
    result += _printRow(rows[6]);
    result += _printRow(rows[7]);
    result += _printRow(rows[8]);
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
}
