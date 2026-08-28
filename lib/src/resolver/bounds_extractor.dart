import 'package:flutter/widgets.dart';
import 'package:flutter_agnetation/src/context/geometry.dart';

/// Extracts global [RectInfo] from an [Element]'s [RenderObject].
class BoundsExtractor {
  const BoundsExtractor();

  /// Returns global bounds or `null` when unavailable (e.g., not a RenderBox).
  RectInfo? rect(Element element) {
    final ro = element.renderObject;
    if (ro is RenderBox) {
      if (!ro.hasSize || !ro.attached) return null;
      try {
        final offset = ro.localToGlobal(Offset.zero);
        final size = ro.size;
        return RectInfo(
          x: offset.dx,
          y: offset.dy,
          width: size.width,
          height: size.height,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Returns [SizeInfo] or `null` when unavailable.
  SizeInfo? size(Element element) {
    final ro = element.renderObject;
    if (ro is RenderBox && ro.hasSize) {
      try {
        return SizeInfo.fromSize(ro.size);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
