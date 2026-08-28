import 'package:flutter/material.dart';
import 'package:flutter_agnetation/src/overlay/activation_toggle.dart';
import 'package:flutter_agnetation/src/overlay/agentation_overlay.dart';
import 'package:flutter_agnetation/src/overlay/circle_toggle.dart';
import 'package:flutter_agnetation/src/overlay/pill_toolbar.dart';
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
      // Initially only circle is visible
      expect(find.byType(CircleToggle), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    });

    testWidgets('circle expands to pill and shows only input popup on select', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: AgentationOverlay.wrap(
            child: Scaffold(
              body: Center(child: ElevatedButton(onPressed: () {}, child: const Text('tapMe'))),
            ),
          ),
        ),
      );
      expect(find.text('tapMe'), findsOneWidget);
      // Tap circle to expand + enable inspect
      await t.tap(find.byType(CircleToggle));
      await t.pumpAndSettle();
      expect(find.byType(PillToolbar), findsOneWidget);
      expect(find.textContaining('Copy'), findsOneWidget);
      // Tap the button via global position — should show only FeedbackPopup input
      final center = t.getCenter(find.text('tapMe'));
      await t.tapAt(center);
      await t.pumpAndSettle();
      expect(find.text('Say what to change…'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      // Full hierarchy should NOT be in popup — only in copied markdown
      expect(find.textContaining('Hierarchy'), findsNothing);
    });
  });
}
