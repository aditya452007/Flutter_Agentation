import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/context/visual_changes.dart';

class MarkdownExporter {
  const MarkdownExporter();

  String export(ContextModel model, {bool screenshotAvailable = false}) {
    final buf = StringBuffer();
    buf.writeln('# Flutter UI Feedback');
    buf.writeln();
    buf.writeln('## Target');
    buf.writeln();
    buf.writeln('- Widget: ${model.facts.widgetType}');
    buf.writeln('- Runtime Type: ${model.facts.runtimeTypeName}');
    buf.writeln();
    buf.writeln('## Source');
    buf.writeln();
    if (model.facts.sourceLocation != null) {
      final s = model.facts.sourceLocation!;
      buf.writeln('- File: ${s.file}');
      buf.writeln('- Line: ${s.line}');
      buf.writeln('- Column: ${s.column}');
    } else {
      buf.writeln('Source unavailable in this build');
    }
    buf.writeln();
    buf.writeln('## Geometry');
    buf.writeln();
    if (model.facts.bounds != null) {
      final b = model.facts.bounds!;
      buf.writeln('- X: ${b.x.toStringAsFixed(0)}');
      buf.writeln('- Y: ${b.y.toStringAsFixed(0)}');
      buf.writeln('- Width: ${b.width.toStringAsFixed(0)}');
      buf.writeln('- Height: ${b.height.toStringAsFixed(0)}');
    } else {
      buf.writeln('Bounds unavailable');
    }
    buf.writeln();
    buf.writeln('## Hierarchy');
    buf.writeln();
    if (model.facts.hierarchy.isEmpty) {
      buf.writeln('_Hierarchy unavailable_');
    } else {
      for (var i = 0; i < model.facts.hierarchy.length; i++) {
        final indent = '  ' * i;
        final isLast = i == model.facts.hierarchy.length - 1;
        final marker = isLast ? ' ◄ selected' : '';
        if (i == 0) {
          buf.writeln('${model.facts.hierarchy[i]}$marker');
        } else {
          buf.writeln('$indent└── ${model.facts.hierarchy[i]}$marker');
        }
      }
    }
    buf.writeln();
    buf.writeln('## Runtime Details');
    buf.writeln();
    if (model.facts.text != null) buf.writeln('- Text: ${model.facts.text}');
    if (model.facts.key != null) buf.writeln('- Key: ${model.facts.key}');
    if (model.facts.semantics != null) buf.writeln('- Semantics: ${model.facts.semantics}');
    if (model.facts.properties != null) {
      for (final e in model.facts.properties!.entries) {
        buf.writeln('- ${e.key}: ${e.value}');
      }
    }
    if (model.facts.text == null && model.facts.key == null && model.facts.semantics == null && model.facts.properties == null) {
      buf.writeln('No additional properties');
    }
    buf.writeln();
    buf.writeln('## Developer Feedback');
    buf.writeln();
    if (model.intent != null && model.intent!.note.isNotEmpty) {
      final escaped = _escapeNote(model.intent!.note);
      buf.writeln('> $escaped');
    } else {
      buf.writeln('> _No feedback provided._');
    }
    buf.writeln();
    buf.writeln('## Visual Evidence');
    buf.writeln();
    if (screenshotAvailable) {
      buf.writeln('Captured screenshot available.');
    } else {
      buf.writeln('No screenshot captured.');
    }
    return buf.toString();
  }

  String exportAll(List<ContextModel> models, {bool screenshotAvailable = false}) {
    if (models.isEmpty) return export(const ContextModel(facts: WidgetFacts(widgetType: 'none', runtimeTypeName: 'none')), screenshotAvailable: screenshotAvailable);
    final out = StringBuffer();
    for (var i = 0; i < models.length; i++) {
      out.writeln('## Annotation ${i + 1}');
      out.writeln();
      out.write(export(models[i], screenshotAvailable: screenshotAvailable));
      if (i != models.length - 1) out.writeln('\n---\n');
    }
    return out.toString();
  }

  String exportVisual(List<VisualChanges> visuals) {
    if (visuals.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln('## Visual Changes');
    buf.writeln();
    for (final v in visuals) {
      if (v is VisualPlacement) {
        final r = v.relativeRect;
        buf.writeln('- Placement: ${v.componentType} at ${r.x.toStringAsFixed(1)}%,${r.y.toStringAsFixed(1)}% ${r.width.toStringAsFixed(1)}%×${r.height.toStringAsFixed(1)}%${v.purpose != null ? ' — ${v.purpose}' : ''}');
      } else if (v is VisualWireframe) {
        buf.writeln('- Wireframe: opacity ${v.opacity.toStringAsFixed(2)}${v.purpose != null ? ', purpose: ${v.purpose}' : ''}');
      } else if (v is VisualRearrange) {
        buf.writeln('- Rearrange: ${v.elementId} ${v.fromRect.width.toStringAsFixed(0)}→${v.toRect.width.toStringAsFixed(0)}');
      }
    }
    return buf.toString();
  }

  String _escapeNote(String note) {
    // Escape fence + heading so note cannot break Markdown structure
    var out = note.replaceAll('```', '\\`\\`\\`');
    out = out.replaceAll('\n', '\n> ');
    // Prevent leading '# ' becoming a heading inside blockquote
    if (out.startsWith('#')) out = '\\$out';
    return out;
  }
}
