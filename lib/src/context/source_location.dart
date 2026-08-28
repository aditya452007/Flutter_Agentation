import 'package:flutter/foundation.dart';

/// Immutable file:line:column triple.
///
/// `null` means unavailable in this build (framework widget, release mode,
/// generated widget). Callers must branch, not fabricate.
@immutable
class SourceLocation {
  const SourceLocation({
    required this.file,
    required this.line,
    required this.column,
  });

  final String file;
  final int line;
  final int column;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'file': file,
        'line': line,
        'column': column,
      };

  factory SourceLocation.fromJson(Map<String, dynamic> json) =>
      SourceLocation(
        file: json['file'] as String,
        line: json['line'] as int,
        column: json['column'] as int,
      );

  SourceLocation copyWith({String? file, int? line, int? column}) =>
      SourceLocation(
        file: file ?? this.file,
        line: line ?? this.line,
        column: column ?? this.column,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceLocation &&
          file == other.file &&
          line == other.line &&
          column == other.column;

  @override
  int get hashCode => Object.hash(file, line, column);

  @override
  String toString() => '$file:$line:$column';
}
