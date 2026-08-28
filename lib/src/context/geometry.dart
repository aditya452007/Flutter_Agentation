import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// Serializable Rect wrapper. Used to keep [ContextModel] pure and
/// json-serializable while still carrying global bounds.
@immutable
class RectInfo {
  const RectInfo({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  factory RectInfo.fromRect(ui.Rect rect) => RectInfo(
        x: rect.left,
        y: rect.top,
        width: rect.width,
        height: rect.height,
      );

  ui.Rect toRect() => ui.Rect.fromLTWH(x, y, width, height);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  factory RectInfo.fromJson(Map<String, dynamic> json) => RectInfo(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );

  RectInfo copyWith({double? x, double? y, double? width, double? height}) =>
      RectInfo(
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RectInfo &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'RectInfo($x,$y ${width}x$height)';
}

/// Serializable Size wrapper.
@immutable
class SizeInfo {
  const SizeInfo({required this.width, required this.height});

  final double width;
  final double height;

  factory SizeInfo.fromSize(ui.Size size) =>
      SizeInfo(width: size.width, height: size.height);

  ui.Size toSize() => ui.Size(width, height);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'width': width,
        'height': height,
      };

  factory SizeInfo.fromJson(Map<String, dynamic> json) => SizeInfo(
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );

  SizeInfo copyWith({double? width, double? height}) => SizeInfo(
        width: width ?? this.width,
        height: height ?? this.height,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizeInfo && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'SizeInfo(${width}x$height)';
}
