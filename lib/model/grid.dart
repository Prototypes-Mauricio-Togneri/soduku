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

  List<Row> _possibleRows(int index) {
    final List<Row> possibleRows = [];
    final List<Column> columns = List.generate(9, (_) => []);

    for (final Row row in rows) {
      for (int i = 0; i < row.length; i++) {
        final int value = row[i];

        if (value > 0) {
          final Column column = columns[i];

          if (!column.contains(value)) {
            columns[i].add(value);
          }
        }
      }
    }

    return possibleRows;
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
