import 'package:flutter/foundation.dart';

import 'geometry.dart';
import 'source_location.dart';
import 'visual_changes.dart';

/// Observed runtime truths. All optional except [widgetType]/[runtimeTypeName].
@immutable
class WidgetFacts {
  const WidgetFacts({
    required this.widgetType,
    required this.runtimeTypeName,
    this.key,
    this.text,
    this.sourceLocation,
    this.bounds,
    this.size,
    this.hierarchy = const <String>[],
    this.semantics,
    this.properties,
  });

  final String widgetType;
  final String runtimeTypeName;
  final String? key;
  final String? text;
  final SourceLocation? sourceLocation;
  final RectInfo? bounds;
  final SizeInfo? size;
  final List<String> hierarchy;
  final String? semantics;
  final Map<String, String>? properties;

  bool get hasSource => sourceLocation != null;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'widgetType': widgetType,
        'runtimeType': runtimeTypeName,
        if (key != null) 'key': key,
        if (text != null) 'text': text,
        if (sourceLocation != null) 'sourceLocation': sourceLocation!.toJson(),
        if (bounds != null) 'bounds': bounds!.toJson(),
        if (size != null) 'size': size!.toJson(),
        'hierarchy': hierarchy,
        if (semantics != null) 'semantics': semantics,
        if (properties != null) 'properties': properties,
      };

  factory WidgetFacts.fromJson(Map<String, dynamic> json) => WidgetFacts(
        widgetType: json['widgetType'] as String,
        runtimeTypeName: (json['runtimeType'] ?? json['runtimeTypeName']) as String,
        key: json['key'] as String?,
        text: json['text'] as String?,
        sourceLocation: json['sourceLocation'] == null
            ? null
            : SourceLocation.fromJson(
                (json['sourceLocation'] as Map).cast<String, dynamic>(),
              ),
        bounds: json['bounds'] == null
            ? null
            : RectInfo.fromJson(
                (json['bounds'] as Map).cast<String, dynamic>(),
              ),
        size: json['size'] == null
            ? null
            : SizeInfo.fromJson(
                (json['size'] as Map).cast<String, dynamic>(),
              ),
        hierarchy:
            (json['hierarchy'] as List<dynamic>).cast<String>().toList(),
        semantics: json['semantics'] as String?,
        properties: json['properties'] == null
            ? null
            : (json['properties'] as Map).cast<String, String>(),
      );

  WidgetFacts copyWith({
    String? widgetType,
    String? runtimeTypeName,
    String? key,
    String? text,
    SourceLocation? sourceLocation,
    RectInfo? bounds,
    SizeInfo? size,
    List<String>? hierarchy,
    String? semantics,
    Map<String, String>? properties,
  }) =>
      WidgetFacts(
        widgetType: widgetType ?? this.widgetType,
        runtimeTypeName: runtimeTypeName ?? this.runtimeTypeName,
        key: key ?? this.key,
        text: text ?? this.text,
        sourceLocation: sourceLocation ?? this.sourceLocation,
        bounds: bounds ?? this.bounds,
        size: size ?? this.size,
        hierarchy: hierarchy ?? this.hierarchy,
        semantics: semantics ?? this.semantics,
        properties: properties ?? this.properties,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetFacts &&
          widgetType == other.widgetType &&
          runtimeTypeName == other.runtimeTypeName &&
          key == other.key &&
          text == other.text &&
          sourceLocation == other.sourceLocation &&
          bounds == other.bounds &&
          size == other.size &&
          listEquals(hierarchy, other.hierarchy) &&
          semantics == other.semantics &&
          mapEquals(properties, other.properties);

  @override
  int get hashCode => Object.hash(
        widgetType,
        runtimeTypeName,
        key,
        text,
        sourceLocation,
        bounds,
        size,
        Object.hashAll(hierarchy),
        semantics,
        properties == null ? null : Object.hashAllUnordered(properties!.entries),
      );

  @override
  String toString() => 'WidgetFacts($widgetType/$runtimeTypeName)';
}

/// Authored developer intent — free-text note.
@immutable
class DeveloperIntent {
  const DeveloperIntent({required this.note});

  final String note;

  Map<String, dynamic> toJson() => <String, dynamic>{'note': note};

  factory DeveloperIntent.fromJson(Map<String, dynamic> json) =>
      DeveloperIntent(note: json['note'] as String);

  DeveloperIntent copyWith({String? note}) =>
      DeveloperIntent(note: note ?? this.note);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeveloperIntent && note == other.note;

  @override
  int get hashCode => note.hashCode;

  @override
  String toString() => 'DeveloperIntent(${note.length} chars)';
}

/// Single source of truth — facts + intent + visual (V2 stub).
@immutable
class ContextModel {
  const ContextModel({
    required this.facts,
    this.intent,
    this.visual,
  });

  final WidgetFacts facts;
  final DeveloperIntent? intent;
  final VisualChanges? visual;

  bool get isSourceAvailable => facts.hasSource;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'facts': facts.toJson(),
        if (intent != null) 'intent': intent!.toJson(),
        // visual is V2 stub — not serialized in V1 when null
      };

  factory ContextModel.fromJson(Map<String, dynamic> json) => ContextModel(
        facts: WidgetFacts.fromJson(
          (json['facts'] as Map).cast<String, dynamic>(),
        ),
        intent: json['intent'] == null
            ? null
            : DeveloperIntent.fromJson(
                (json['intent'] as Map).cast<String, dynamic>(),
              ),
        // visual omitted in V1 json
      );

  ContextModel copyWith({
    WidgetFacts? facts,
    DeveloperIntent? intent,
    VisualChanges? visual,
  }) =>
      ContextModel(
        facts: facts ?? this.facts,
        intent: intent ?? this.intent,
        visual: visual ?? this.visual,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextModel &&
          facts == other.facts &&
          intent == other.intent &&
          visual == other.visual;

  @override
  int get hashCode => Object.hash(facts, intent, visual);

  @override
  String toString() => 'ContextModel(${facts.widgetType}, hasIntent=${intent != null})';
}
