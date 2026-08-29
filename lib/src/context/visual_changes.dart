import 'package:flutter/foundation.dart';
import 'package:flutter_agnetation/src/context/geometry.dart';

/// V2 sealed visual changes — spatial hints, not source mutation.
sealed class VisualChanges {
  const VisualChanges();
}

/// A component dragged from palette onto canvas.
@immutable
class VisualPlacement extends VisualChanges {
  const VisualPlacement({
    required this.componentType,
    required this.relativeRect,
    this.purpose,
  });

  /// e.g. "Card", "ElevatedButton"
  final String componentType;

  /// Relative rect as percentages (0-100) of viewport, stored as RectInfo
  final RectInfo relativeRect;

  final String? purpose;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': 'placement',
        'componentType': componentType,
        'relativeRect': relativeRect.toJson(),
        if (purpose != null) 'purpose': purpose,
      };
}

/// Rearrange an existing element (V2 stub for now).
@immutable
class VisualRearrange extends VisualChanges {
  const VisualRearrange({
    required this.elementId,
    required this.fromRect,
    required this.toRect,
  });

  final String elementId;
  final RectInfo fromRect;
  final RectInfo toRect;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': 'rearrange',
        'elementId': elementId,
        'fromRect': fromRect.toJson(),
        'toRect': toRect.toJson(),
      };
}

/// Wireframe mode state.
@immutable
class VisualWireframe extends VisualChanges {
  const VisualWireframe({required this.opacity, this.purpose});

  /// 0.0 - 1.0
  final double opacity;
  final String? purpose;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': 'wireframe',
        'opacity': opacity,
        if (purpose != null) 'purpose': purpose,
      };
}
