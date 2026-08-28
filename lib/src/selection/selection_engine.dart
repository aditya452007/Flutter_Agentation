import 'package:flutter/rendering.dart' hide SelectionResult;
import 'package:flutter/widgets.dart';
import 'package:flutter_agnetation/src/resolver/bounds_extractor.dart';
import 'package:flutter_agnetation/src/resolver/widget_resolver.dart';
import 'package:flutter_agnetation/src/selection/hit_test_adapter.dart';
import 'package:flutter_agnetation/src/selection/selection_result.dart';

/// Performs hit-testing and resolves [WidgetFacts] for the deepest hittable.
class SelectionEngine extends ChangeNotifier {
  SelectionEngine({
    WidgetResolver? resolver,
    HitTestAdapter? hitTest,
    BoundsExtractor? bounds,
  })  : _resolver = resolver ?? const WidgetResolver(),
        _hitTest = hitTest ?? const FlutterHitTestAdapter(),
        _bounds = bounds ?? const BoundsExtractor();

  final WidgetResolver _resolver;
  final HitTestAdapter _hitTest;
  final BoundsExtractor _bounds;

  final ValueNotifier<SelectionResult?> selected =
      ValueNotifier<SelectionResult?>(null);

  /// Hit-tests at [globalOffset] and updates [selected].
  /// Returns `null` when nothing hittable (offscreen).
  SelectionResult? selectAt(Offset globalOffset) {
    _hitTest.hitTest(globalOffset);
    final target = _deepestByBounds(globalOffset);
    if (target == null) {
      selected.value = null;
      notifyListeners();
      return null;
    }
    final facts = _resolver.resolve(target);
    final rect = _bounds.rect(target);
    final selection = SelectionResult(
      element: target,
      facts: facts,
      globalOffset: globalOffset,
      bounds: rect,
    );
    selected.value = selection;
    notifyListeners();
    return selection;
  }

  /// Clears the current selection.
  void clear() {
    selected.value = null;
    notifyListeners();
  }

  @override
  void dispose() {
    selected.dispose();
    super.dispose();
  }

  bool _isLeafText(String type) => type == 'Text' || type == 'RichText' || type == 'SelectableText';

  Element? _deepestByBounds(Offset globalOffset) {
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) return null;
    Element? deepest;
    int deepestDepth = -1;

    void walk(Element element, int depth) {
      final ro = element.renderObject;
      if (ro is RenderBox && ro.hasSize && ro.attached) {
        // Skip view-level boxes that cover the whole window (like RenderView)
        if (ro is RenderView) {
          // do not consider view as hittable — continue to children
        } else {
          try {
            final global = ro.localToGlobal(Offset.zero);
            final rect = global & ro.size;
            if (rect.contains(globalOffset)) {
              if (depth > deepestDepth) {
                deepest = element;
                deepestDepth = depth;
              }
            }
          } catch (_) {}
        }
      }
      element.visitChildren((child) => walk(child, depth + 1));
    }

    walk(root, 0);
    if (deepest == null) return null;
    // Lift from Text leaf to its button-like ancestor when the leaf is just text
    // inside a tappable. This gives developers the widget they think they tapped.
    final deepestType = deepest!.widget.runtimeType.toString();
    if (_isLeafText(deepestType)) {
      Element? lifted;
      final ancestors = <Element>[];
      deepest!.visitAncestorElements((a) {
        ancestors.add(a);
        return true;
      });
      for (final anc in ancestors) {
        final ro = anc.renderObject;
        if (ro is RenderBox && ro.hasSize && ro.attached && ro is! RenderView) {
          try {
            final rect = ro.localToGlobal(Offset.zero) & ro.size;
            if (rect.contains(globalOffset)) {
              final t = anc.widget.runtimeType.toString();
              if (!_isLeafText(t) && !t.startsWith('_')) {
                if (t.contains('Button') ||
                    t.contains('Card') ||
                    t.contains('Chip') ||
                    t.contains('Tile')) {
                  return anc;
                }
                lifted ??= anc;
              }
            }
          } catch (_) {}
        }
      }
      if (lifted != null) return lifted;
    }
    return deepest;
  }
}
