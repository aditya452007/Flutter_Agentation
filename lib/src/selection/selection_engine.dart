import 'package:flutter/rendering.dart' hide SelectionResult;
import 'package:flutter/widgets.dart';
import 'package:flutter_agnetation/src/resolver/bounds_extractor.dart';
import 'package:flutter_agnetation/src/resolver/widget_resolver.dart';
import 'package:flutter_agnetation/src/selection/hit_test_adapter.dart';
import 'package:flutter_agnetation/src/selection/selection_result.dart';

/// Performs hit-testing and resolves [WidgetFacts] for the smallest-area hittable.
/// Also tracks hover for desktop/web.
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

  final ValueNotifier<SelectionResult?> selected = ValueNotifier<SelectionResult?>(null);
  final ValueNotifier<SelectionResult?> hovered = ValueNotifier<SelectionResult?>(null);

  /// Hit-tests at [globalOffset] and updates [selected].
  SelectionResult? selectAt(Offset globalOffset) {
    _hitTest.hitTest(globalOffset);
    final target = _bestCandidate(globalOffset);
    if (target == null) {
      selected.value = null;
      notifyListeners();
      return null;
    }
    final facts = _resolver.resolve(target);
    final rect = _bounds.rect(target);
    final selection = SelectionResult(element: target, facts: facts, globalOffset: globalOffset, bounds: rect);
    selected.value = selection;
    notifyListeners();
    return selection;
  }

  /// Updates hovered (not selected) for mouse move. No-op on touch.
  SelectionResult? hoverAt(Offset globalOffset) {
    final target = _bestCandidate(globalOffset);
    if (target == null) {
      if (hovered.value != null) {
        hovered.value = null;
        notifyListeners();
      }
      return null;
    }
    // Avoid churn: same element as before
    if (hovered.value?.element == target) return hovered.value;
    final facts = _resolver.resolve(target);
    final rect = _bounds.rect(target);
    final result = SelectionResult(element: target, facts: facts, globalOffset: globalOffset, bounds: rect);
    hovered.value = result;
    notifyListeners();
    return result;
  }

  void clearHover() {
    if (hovered.value != null) {
      hovered.value = null;
      notifyListeners();
    }
  }

  void clear() {
    selected.value = null;
    hovered.value = null;
    notifyListeners();
  }

  @override
  void dispose() {
    selected.dispose();
    hovered.dispose();
    super.dispose();
  }

  bool _isLeafText(String type) => type == 'Text' || type == 'RichText' || type == 'SelectableText';
  bool _isPrivate(String type) => type.startsWith('_');
  bool _isRelevant(String type) {
    if (_isPrivate(type)) return false;
    if (_isLeafText(type)) return true; // keep text as candidate but lift later
    return true;
  }

  Element? _bestCandidate(Offset globalOffset) {
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) return null;
    final candidates = <({Element element, double area})>[];

    void walk(Element element) {
      final ro = element.renderObject;
      if (ro is RenderBox && ro.hasSize && ro.attached && ro is! RenderView) {
        try {
          final global = ro.localToGlobal(Offset.zero);
          final rect = global & ro.size;
          if (rect.contains(globalOffset)) {
            final type = element.widget.runtimeType.toString();
            if (_isRelevant(type)) {
              final area = ro.size.width * ro.size.height;
              // Filter overly large background (e.g., Scaffold 800x600) unless no smaller candidate?
              // Keep all, smallest-area will naturally prefer smaller.
              candidates.add((element: element, area: area));
            }
          }
        } catch (_) {}
      }
      element.visitChildren(walk);
    }

    walk(root);
    if (candidates.isEmpty) return null;
    // Prefer smallest-area among non-Text candidates; fall back to Text if only Texts hit
    final nonText = candidates.where((c) => !_isLeafText(c.element.widget.runtimeType.toString())).toList();
    final pool = nonText.isNotEmpty ? nonText : candidates;
    pool.sort((a, b) => a.area.compareTo(b.area));
    final best = pool.first.element;
    // Lift Text leaf to button-like ancestor if best is Text and a nearby non-Text ancestor also contains point
    final bestType = best.widget.runtimeType.toString();
    if (_isLeafText(bestType)) {
      final ancestors = <Element>[];
      best.visitAncestorElements((a) {
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
              if (!_isLeafText(t) && !_isPrivate(t)) {
                if (t.contains('Button') || t.contains('Card') || t.contains('Chip') || t.contains('Tile')) return anc;
              }
            }
          } catch (_) {}
        }
      }
    }
    return best;
  }
}
