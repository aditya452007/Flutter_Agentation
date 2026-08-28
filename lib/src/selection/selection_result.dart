import 'package:flutter/widgets.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/context/geometry.dart';

/// Result of a hit-test selection.
class SelectionResult {
  const SelectionResult({
    required this.element,
    required this.facts,
    required this.globalOffset,
    required this.bounds,
  });

  /// The deepest hittable [Element].
  final Element element;

  /// Resolved facts for the element.
  final WidgetFacts facts;

  /// The global pointer offset that produced this result.
  final Offset globalOffset;

  /// Global bounds when available (RenderBox).
  final RectInfo? bounds;

  bool get hasBounds => bounds != null;
}
