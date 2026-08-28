import 'package:flutter/widgets.dart';

/// Walks ancestor [Element]s and returns widget type names root → leaf, capped.
/// Filters private and overly noisy framework types to keep hierarchy
/// developer-relevant for agents and Markdown.
class HierarchyExtractor {
  const HierarchyExtractor();

  static const Set<String> _noisy = <String>{
    'Semantics',
    'Listener',
    'MouseRegion',
    'Builder',
    'DefaultSelectionStyle',
    'MediaQuery',
    'Directionality',
    'Overlay',
    'Focus',
    'Actions',
    'FocusScope',
    'SemanticsGestureHandler',
  };

  bool _isRelevant(String type) {
    if (type.startsWith('_')) return false;
    // Strip generic args e.g. NotificationListener<...>
    final base = type.contains('<') ? type.substring(0, type.indexOf('<')) : type;
    if (_noisy.contains(base)) return false;
    return true;
  }

  /// Returns filtered list root → leaf, capped at [maxDepth].
  List<String> path(Element element, {int maxDepth = 20}) {
    final List<String> chain = <String>[];
    element.visitAncestorElements((Element ancestor) {
      chain.add(ancestor.widget.runtimeType.toString());
      return true;
    });
    final rootToParent = chain.reversed.toList();
    final full = <String>[...rootToParent, element.widget.runtimeType.toString()];
    // Filter to relevant types, but always keep the target leaf even if noisy?
    // Keep leaf regardless, filter ancestors.
    final filtered = <String>[];
    for (var i = 0; i < full.length - 1; i++) {
      if (_isRelevant(full[i])) filtered.add(full[i]);
    }
    // Always keep leaf
    filtered.add(full.last);
    if (filtered.length > maxDepth) {
      return filtered.sublist(filtered.length - maxDepth);
    }
    return filtered;
  }
}
