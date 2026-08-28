import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agnetation/agentation.dart';

void main() {
  group('RectInfo', () {
    test('equality and copyWith', () {
      const a = RectInfo(x: 0, y: 0, width: 10, height: 20);
      const b = RectInfo(x: 0, y: 0, width: 10, height: 20);
      expect(a, b);
      expect(a.copyWith(width: 30).width, 30);
    });

    test('fromRect / toRect', () {
      const info = RectInfo(x: 1, y: 2, width: 3, height: 4);
      final rect = info.toRect();
      expect(rect.left, 1);
      expect(RectInfo.fromRect(rect), info);
    });

    test('hashCode stable', () {
      const r = RectInfo(x: 5, y: 6, width: 7, height: 8);
      expect(r.hashCode, r.copyWith().hashCode);
    });
  });

  group('SizeInfo', () {
    test('equality and copyWith', () {
      const a = SizeInfo(width: 10, height: 20);
      const b = SizeInfo(width: 10, height: 20);
      expect(a, b);
      expect(a.copyWith(height: 30).height, 30);
    });

    test('fromSize / toSize', () {
      const info = SizeInfo(width: 3, height: 4);
      final size = info.toSize();
      expect(size.width, 3);
      expect(SizeInfo.fromSize(size), info);
    });
  });
}
