import 'dart:io';
import 'dart:math';

typedef Row = List<int>;

class Grid {
  final List<Row> rows;

  const Grid({required this.rows});

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

  String _printCell(int value) => value == 0 ? ' ' : value.toString();
}
