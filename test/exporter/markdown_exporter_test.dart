import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/context/geometry.dart';
import 'package:flutter_agnetation/src/context/source_location.dart';
import 'package:flutter_agnetation/src/exporter/markdown_exporter.dart';

void main() {
  const exporter = MarkdownExporter();

  test('full model snapshot is deterministic', () {
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
      intent: DeveloperIntent(note: 'Make this button more rounded and slightly taller.'),
    );
    final a = exporter.export(model);
    final b = exporter.export(model);
    expect(a, b);
    expect(a, contains('## Target'));
    expect(a, contains('ElevatedButton'));
    expect(a, contains('lib/screens/home.dart'));
    expect(a, contains('X: 32'));
    expect(a, contains('Scaffold'));
    expect(a, contains('Make this button more rounded'));
    expect(a, contains('No screenshot captured.'));
  });

  test('source-null renders unavailable', () {
    const model = ContextModel(
      facts: WidgetFacts(
        widgetType: 'RenderFlex',
        runtimeTypeName: 'RenderFlex',
        hierarchy: <String>['Scaffold', 'RenderFlex'],
      ),
    );
    final md = exporter.export(model);
    expect(md, contains('Source unavailable in this build'));
    expect(md, isNot(contains(' - File:')));
  });

  test('bounds-null renders unavailable', () {
    const model = ContextModel(
      facts: WidgetFacts(
        widgetType: 'Divider',
        runtimeTypeName: 'Divider',
        hierarchy: <String>['Scaffold', 'Divider'],
      ),
    );
    final md = exporter.export(model);
    expect(md, contains('Bounds unavailable'));
  });

  test('no intent renders placeholder', () {
    const model = ContextModel(
      facts: WidgetFacts(widgetType: 'Text', runtimeTypeName: 'Text', hierarchy: <String>['Scaffold', 'Text']),
    );
    final md = exporter.export(model);
    expect(md, contains('_No feedback provided._'));
  });

  test('screenshot flag adds evidence line', () {
    const model = ContextModel(
      facts: WidgetFacts(widgetType: 'Button', runtimeTypeName: 'Button', hierarchy: <String>['Button']),
    );
    expect(exporter.export(model, screenshotAvailable: true), contains('Captured screenshot available.'));
    expect(exporter.export(model), contains('No screenshot captured.'));
  });

  test('hierarchy not duplicated', () {
    const model = ContextModel(
      facts: WidgetFacts(
        widgetType: 'X',
        runtimeTypeName: 'X',
        hierarchy: <String>['A', 'B', 'C'],
      ),
    );
    final md = exporter.export(model);
    // Should have exactly one "## Hierarchy" section
    expect('## Hierarchy'.allMatches(md).length, 1);
    // Tree markers: first entry no marker, rest have └──
    expect(md.split('└──').length - 1, 2);
  });

  test('note escaping does not break headings', () {
    const model = ContextModel(
      facts: WidgetFacts(widgetType: 'X', runtimeTypeName: 'X', hierarchy: <String>['X']),
      intent: DeveloperIntent(note: '# Heading\n```dart\ncode```'),
    );
    final md = exporter.export(model);
    expect(md, contains('\\# Heading'));
    expect(md, contains('\\`\\`\\`'));
  });
}
