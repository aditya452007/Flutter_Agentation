import 'package:flutter/material.dart';
import 'package:flutter_agnetation/src/overlay/activation_toggle.dart';
import 'package:flutter_agnetation/src/overlay/agentation_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActivationToggle', () {
    testWidgets('shows Agentation logo pill when disabled', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivationToggle(isEnabled: false, onToggle: () {}),
          ),
        ),
      );
      expect(find.text('Agentation'), findsOneWidget);
      expect(find.text('Tap to inspect UI'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    });

    testWidgets('shows Inspecting when enabled', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivationToggle(isEnabled: true, onToggle: () {}),
          ),
        ),
      );
      expect(find.text('Inspecting…'), findsOneWidget);
      expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
    });
  });

  group('AgentationOverlay', () {
    testWidgets('toggle is always visible in Demo-like overlay', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: AgentationOverlay.wrap(
            child: const Scaffold(body: Text('hello')),
          ),
        ),
      );
      // Toggle must be present even without selection
      expect(find.text('Agentation'), findsOneWidget);
      expect(find.byType(ActivationToggle), findsOneWidget);
    });

    testWidgets('shows highlight + panel after selection', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: AgentationOverlay.wrap(
            child: Scaffold(
              body: Center(child: ElevatedButton(onPressed: () {}, child: const Text('tapMe'))),
            ),
          ),
        ),
      );
      // Initially no highlight
      expect(find.text('tapMe'), findsOneWidget);
      // Enable inspection
      await t.tap(find.text('Agentation'));
      await t.pumpAndSettle();
      expect(find.text('Inspecting…'), findsOneWidget);
      // Tap the button via global position
      final center = t.getCenter(find.text('tapMe'));
      await t.tapAt(center);
      await t.pumpAndSettle();
      // Highlight label should appear (widgetType or hierarchy)
      // At least the info panel should be visible with Widget section
      expect(find.textContaining('Widget'), findsWidgets);
    });
  });
}
