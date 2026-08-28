import 'package:flutter/foundation.dart';
import 'package:flutter_agnetation/src/annotation/annotation_manager.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/exporter/markdown_exporter.dart';
import 'package:flutter_agnetation/src/selection/selection_engine.dart';
import 'package:flutter_agnetation/src/selection/selection_result.dart';

/// Owns inspection activation, selected element, annotation and export state.
class AgentationController extends ChangeNotifier {
  AgentationController({SelectionEngine? engine, AnnotationManager? annotation, MarkdownExporter? exporter})
      : _engine = engine ?? SelectionEngine(),
        _annotation = annotation ?? AnnotationManager(),
        _exporter = exporter ?? const MarkdownExporter() {
    _engine.selected.addListener(_onEngineSelection);
    _engine.addListener(_onEngineChange);
    _annotation.bindToSelection(_engine.selected);
  }

  final SelectionEngine _engine;
  final AnnotationManager _annotation;
  final MarkdownExporter _exporter;

  final ValueNotifier<bool> isEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<SelectionResult?> selected = ValueNotifier<SelectionResult?>(null);

  SelectionEngine get engine => _engine;
  AnnotationManager get annotation => _annotation;
  MarkdownExporter get exporter => _exporter;

  /// Current ContextModel derived from selection + annotation (single source of truth)
  ContextModel? get currentContext {
    final sel = selected.value;
    if (sel == null) return null;
    return ContextModel(
      facts: sel.facts,
      intent: _annotation.current.value,
    );
  }

  String? get currentMarkdown {
    final ctx = currentContext;
    if (ctx == null) return null;
    return _exporter.export(ctx);
  }

  void toggle() {
    if (isEnabled.value) {
      disable();
    } else {
      enable();
    }
  }

  void enable() {
    isEnabled.value = true;
    notifyListeners();
  }

  void disable() {
    isEnabled.value = false;
    selected.value = null;
    _engine.clear();
    _annotation.clear();
    notifyListeners();
  }

  void _onEngineSelection() {
    if (isEnabled.value) {
      selected.value = _engine.selected.value;
    }
  }

  void _onEngineChange() => notifyListeners();

  @override
  void dispose() {
    _engine.selected.removeListener(_onEngineSelection);
    _engine.removeListener(_onEngineChange);
    isEnabled.dispose();
    selected.dispose();
    _engine.dispose();
    _annotation.dispose();
    super.dispose();
  }
}
