import 'package:flutter/widgets.dart';

/// Extracts a string representation of an [Element]'s [Key].
class KeyResolver {
  const KeyResolver();

  /// Returns `widget.key.toString()` or `null` when none.
  String? keyOf(Element element) {
    final k = element.widget.key;
    if (k == null) return null;
    try {
      return k.toString();
    } catch (_) {
      return null;
    }
  }
}
