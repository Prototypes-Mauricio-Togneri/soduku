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

  String _printRow(Row row) =>
      '│ ${row[0]} ${row[1]} ${row[2]} │ ${row[3]} ${row[4]} ${row[5]} │ ${row[6]} ${row[7]} ${row[8]} │\n';
}
