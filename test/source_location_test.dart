import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agnetation/agentation.dart';

void main() {
  group('SourceLocation (standalone)', () {
    test('equality includes file', () {
      const a = SourceLocation(file: 'lib/a.dart', line: 1, column: 1);
      const b = SourceLocation(file: 'lib/b.dart', line: 1, column: 1);
      expect(a == b, false);
    });

    test('hashCode stable', () {
      const loc = SourceLocation(file: 'x.dart', line: 2, column: 3);
      expect(loc.hashCode, loc.copyWith().hashCode);
    });

    test('fromJson validates required keys', () {
      final json = <String, dynamic>{'file': 'f.dart', 'line': 7, 'column': 8};
      expect(SourceLocation.fromJson(json).toString(), 'f.dart:7:8');
    });
  });
}
