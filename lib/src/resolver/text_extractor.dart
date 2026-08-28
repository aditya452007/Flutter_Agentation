import 'package:flutter/widgets.dart';

/// Extracts textual content from an [Element] when present.
class TextExtractor {
  const TextExtractor();

  /// Returns text if the widget is a [Text] or contains one, else `null`.
  String? text(Element element) {
    final widget = element.widget;
    if (widget is Text) {
      final data = widget.data;
      if (data != null && data.isNotEmpty) return data;
      // Text.rich case — join TextSpans (shallow).
      final textSpan = widget.textSpan;
      if (textSpan != null) {
        final plain = textSpan.toPlainText();
        if (plain.isNotEmpty) return plain;
      }
    }
    // Also check semantics label for image-like widgets (fallback).
    // Avoid traversing children — keep sync/fast.
    return null;
  }
}
