import 'package:flutter/widgets.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/resolver/bounds_extractor.dart';
import 'package:flutter_agnetation/src/resolver/hierarchy_extractor.dart';
import 'package:flutter_agnetation/src/resolver/key_resolver.dart';
import 'package:flutter_agnetation/src/resolver/source_resolver.dart';
import 'package:flutter_agnetation/src/resolver/text_extractor.dart';

/// Facade that delegates to sub-extractors and returns [WidgetFacts].
class WidgetResolver {
  const WidgetResolver({
    SourceResolver? source,
    BoundsExtractor? bounds,
    HierarchyExtractor? hierarchy,
    TextExtractor? text,
    KeyResolver? key,
  })  : _source = source ?? const SourceResolver(),
        _bounds = bounds ?? const BoundsExtractor(),
        _hierarchy = hierarchy ?? const HierarchyExtractor(),
        _text = text ?? const TextExtractor(),
        _key = key ?? const KeyResolver();

  final SourceResolver _source;
  final BoundsExtractor _bounds;
  final HierarchyExtractor _hierarchy;
  final TextExtractor _text;
  final KeyResolver _key;

  /// Resolves [WidgetFacts] for [element]. Never throws — returns best-effort.
  WidgetFacts resolve(Element element) {
    final loc = _source.location(element);
    final rect = _bounds.rect(element);
    final sz = _bounds.size(element);
    final path = _hierarchy.path(element);
    final txt = _text.text(element);
    final k = _key.keyOf(element);
    final widgetType = element.widget.runtimeType.toString();
    // runtimeTypeName is the same as widgetType in this context (widget's type)
    // but kept as separate field for exporter symmetry.
    return WidgetFacts(
      widgetType: widgetType,
      runtimeTypeName: widgetType,
      key: k,
      text: txt,
      sourceLocation: loc,
      bounds: rect,
      size: sz,
      hierarchy: path,
    );
  }
}
