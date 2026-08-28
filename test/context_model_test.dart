import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agnetation/agentation.dart';

void main() {
  group('SourceLocation', () {
    test('toString is file:line:column', () {
      const loc = SourceLocation(file: 'lib/screens/home.dart', line: 143, column: 12);
      expect(loc.toString(), 'lib/screens/home.dart:143:12');
    });

    test('equality and copyWith', () {
      const a = SourceLocation(file: 'a.dart', line: 1, column: 2);
      const b = SourceLocation(file: 'a.dart', line: 1, column: 2);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.copyWith(line: 10).line, 10);
    });

    test('json round-trip', () {
      const loc = SourceLocation(file: 'lib/main.dart', line: 10, column: 4);
      final clone = SourceLocation.fromJson(loc.toJson());
      expect(clone, loc);
    });
  });

  group('RectInfo/SizeInfo', () {
    test('RectInfo json round-trip', () {
      const r = RectInfo(x: 32, y: 540, width: 320, height: 52);
      expect(RectInfo.fromJson(r.toJson()), r);
      expect(r.toRect().width, 320);
    });

    test('SizeInfo json round-trip', () {
      const s = SizeInfo(width: 100, height: 50);
      expect(SizeInfo.fromJson(s.toJson()), s);
      expect(s.toSize().width, 100);
    });
  });

  group('ContextModel', () {
    WidgetFacts fullFacts() => const WidgetFacts(
          widgetType: 'ElevatedButton',
          runtimeTypeName: 'ElevatedButton',
          key: '[MyKey]',
          text: 'Get Started',
          sourceLocation: SourceLocation(file: 'lib/screens/home.dart', line: 143, column: 12),
          bounds: RectInfo(x: 32, y: 540, width: 320, height: 52),
          hierarchy: <String>['Scaffold', 'Column', 'Card', 'ElevatedButton'],
          semantics: 'button',
          properties: <String, String>{'color': 'primary'},
        );

    test('full model json round-trip', () {
      const model = ContextModel(
        facts: WidgetFacts(
          widgetType: 'ElevatedButton',
          runtimeTypeName: 'ElevatedButton',
          key: '[MyKey]',
          text: 'Get Started',
          sourceLocation: SourceLocation(file: 'lib/screens/home.dart', line: 143, column: 12),
          bounds: RectInfo(x: 32, y: 540, width: 320, height: 52),
          hierarchy: <String>['Scaffold', 'Column', 'Card', 'ElevatedButton'],
          semantics: 'button',
        ),
        intent: DeveloperIntent(note: 'Make more rounded'),
      );
      final clone = ContextModel.fromJson(model.toJson());
      expect(clone, model);
      expect(clone.isSourceAvailable, true);
    });

    test('source-null model still valid', () {
      const facts = WidgetFacts(
        widgetType: 'RenderFlex',
        runtimeTypeName: 'RenderFlex',
        hierarchy: <String>['Scaffold', 'Column', 'RenderFlex'],
      );
      const model = ContextModel(facts: facts);
      expect(model.isSourceAvailable, false);
      final clone = ContextModel.fromJson(model.toJson());
      expect(clone.facts.sourceLocation, isNull);
      expect(clone.facts.widgetType, 'RenderFlex');
    });

    test('bounds-null model still valid', () {
      const facts = WidgetFacts(
        widgetType: 'Divider',
        runtimeTypeName: 'Divider',
        hierarchy: <String>['Scaffold', 'Divider'],
      );
      const model = ContextModel(facts: facts);
      expect(model.facts.bounds, isNull);
      expect(ContextModel.fromJson(model.toJson()).facts.bounds, isNull);
    });

    test('hierarchy capped note via model equality', () {
      // L01 cap is enforced at resolver, but model must store whatever given
      const facts = WidgetFacts(
        widgetType: 'Text',
        runtimeTypeName: 'Text',
        hierarchy: <String>['a', 'b', 'c', 'd', 'e'],
      );
      const model = ContextModel(facts: facts);
      expect(model.facts.hierarchy.length, 5);
    });

    test('intent trimming is caller responsibility but model preserves', () {
      const intent = DeveloperIntent(note: '  hello  ');
      expect(intent.note, '  hello  ');
      // manager in L06 will trim; model is verbatim
      const model = ContextModel(
        facts: WidgetFacts(widgetType: 'Text', runtimeTypeName: 'Text'),
        intent: intent,
      );
      expect(model.intent!.note, '  hello  ');
    });

    test('isSourceAvailable helper', () {
      expect(fullFacts().hasSource, true);
      const noSource = WidgetFacts(widgetType: 'X', runtimeTypeName: 'X');
      expect(noSource.hasSource, false);
    });

    test('deterministic json key order', () {
      const a = ContextModel(
        facts: WidgetFacts(widgetType: 'A', runtimeTypeName: 'A', hierarchy: <String>['A']),
        intent: DeveloperIntent(note: 'note'),
      );
      expect(a.toJson().keys.first, 'facts');
    });

    test('copyWith preserves values', () {
      const base = ContextModel(facts: WidgetFacts(widgetType: 'A', runtimeTypeName: 'A', hierarchy: <String>['A']));
      final copy = base.copyWith(intent: const DeveloperIntent(note: 'hi'));
      expect(copy.intent!.note, 'hi');
      expect(copy.facts.widgetType, 'A');
    });

    test('fullFacts helper produces expected map', () {
      // uses helper defined above
      final facts = fullFacts();
      expect(facts.text, 'Get Started');
      expect(facts.properties!['color'], 'primary');
    });
  });
}



