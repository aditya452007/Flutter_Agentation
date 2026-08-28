import 'package:flutter/widgets.dart';
import 'package:flutter_agnetation/src/context/source_location.dart';

/// Resolves [SourceLocation] from an [Element] when available.
///
/// Uses Flutter's debug creation tracking (`_HasCreationLocation._location`)
/// when present in debug builds. Falls back gracefully to `null`.
class SourceResolver {
  const SourceResolver();

  SourceLocation? location(Element element) {
    // Try Element first, then Widget — both may carry _location in debug.
    final loc = _extractFrom(element) ?? _extractFrom(element.widget);
    if (loc != null) return _normalize(loc);
    // Fallback: parse diagnostics string for a .dart file reference
    final fallback = _fromDiagnosticsString(element);
    if (fallback != null) return _normalize(fallback);
    return null;
  }

  SourceLocation? _extractFrom(Object object) {
    try {
      // ignore: avoid_dynamic_calls, reason: private _location access is required
      final dynamic dyn = object;
      final dynamic raw = dyn._location;
      if (raw == null) return null;
      // ignore: avoid_dynamic_calls
      final dynamic file = raw.file;
      // ignore: avoid_dynamic_calls
      final dynamic line = raw.line;
      // ignore: avoid_dynamic_calls
      final dynamic column = raw.column;
      if (file is String && file.contains('.dart') && line is int && line > 0) {
        return SourceLocation(
          file: file,
          line: line,
          column: column is int ? column : 0,
        );
      }
      // Some Flutter versions expose as _Location with .path instead of .file
      // ignore: avoid_dynamic_calls
      final dynamic path = raw.path;
      if (path is String && path.contains('.dart') && line is int && line > 0) {
        return SourceLocation(file: path, line: line, column: column is int ? column : 0);
      }
    } on Object catch (_) {}
    return null;
  }

  SourceLocation? _fromDiagnosticsString(Element element) {
    try {
      final diag = element.toDiagnosticsNode().toStringDeep();
      // Look for something like "file:///C:/.../lib/main.dart:10:5"
      final reg = RegExp(r'([^\s"]+\.dart):(\d+):(\d+)');
      final match = reg.firstMatch(diag);
      if (match != null) {
        return SourceLocation(
          file: match.group(1)!,
          line: int.parse(match.group(2)!),
          column: int.parse(match.group(3)!),
        );
      }
    } on Object catch (_) {}
    return null;
  }

  SourceLocation _normalize(SourceLocation loc) {
    var file = loc.file;
    // Normalize file:// URIs and absolute paths to relative lib/... form
    // e.g. "file:///C:/Users/x/project/lib/screens/home.dart" -> "lib/screens/home.dart"
    // e.g. "package:my_app/screens/home.dart" -> "lib/screens/home.dart"
    if (file.startsWith('file://')) {
      file = Uri.parse(file).path;
    }
    // Extract lib/... segment if present
    final libIndex = file.indexOf('lib/');
    if (libIndex != -1) {
      file = file.substring(libIndex);
    } else if (file.contains('package:')) {
      // package:my_app/foo.dart -> lib/foo.dart (best-effort)
      final slash = file.indexOf('/');
      if (slash != -1 && slash + 1 < file.length) {
        file = 'lib/${file.substring(slash + 1)}';
      }
    }
    // Ensure forward slashes
    file = file.replaceAll(r'\', '/');
    return SourceLocation(file: file, line: loc.line, column: loc.column);
  }
}
