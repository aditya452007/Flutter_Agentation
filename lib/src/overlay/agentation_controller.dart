import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_agnetation/src/annotation/annotation_history.dart';
import 'package:flutter_agnetation/src/visual/layout_controller.dart';
import 'package:flutter_agnetation/src/annotation/annotation_manager.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/exporter/markdown_exporter.dart';
import 'package:flutter_agnetation/src/selection/selection_engine.dart';
import 'package:flutter_agnetation/src/selection/selection_result.dart';

/// Owns inspection state: activation, hover, selection, history, pause/visibility.
class AgentationController extends ChangeNotifier {
  AgentationController({SelectionEngine? engine, AnnotationManager? annotation, AnnotationHistory? history, LayoutController? layout, MarkdownExporter? exporter})
      : _engine = engine ?? SelectionEngine(),
        _annotation = annotation ?? AnnotationManager(),
        _history = history ?? AnnotationHistory(),
        _layout = layout ?? LayoutController(),
        _exporter = exporter ?? const MarkdownExporter() {
    _engine.selected.addListener(_onEngineSelection);
    _engine.hovered.addListener(_onEngineHover);
    _engine.addListener(_onEngineChange);
    _annotation.bindToSelection(_engine.selected);
    _layout.addListener(_onEngineChange);
    _layout.placements.addListener(_onEngineChange);
    _layout.wireframeOpacity.addListener(_onEngineChange);
  }

  final SelectionEngine _engine;
  final AnnotationManager _annotation;
  final AnnotationHistory _history;
  final LayoutController _layout;
  final MarkdownExporter _exporter;

  final ValueNotifier<bool> isEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPaused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLayoutMode = ValueNotifier<bool>(false);
  final ValueNotifier<SelectionResult?> selected = ValueNotifier<SelectionResult?>(null);
  final ValueNotifier<SelectionResult?> hovered = ValueNotifier<SelectionResult?>(null);
  final ValueNotifier<SelectionResult?> pendingPopupFor = ValueNotifier<SelectionResult?>(null);

  SelectionEngine get engine => _engine;
  AnnotationManager get annotation => _annotation;
  AnnotationHistory get history => _history;
  LayoutController get layout => _layout;
  MarkdownExporter get exporter => _exporter;

  ContextModel? get currentContext {
    final sel = selected.value;
    if (sel == null) return null;
    return ContextModel(facts: sel.facts, intent: _annotation.current.value);
  }

  String exportAll() {
    final models = _history.toContextModels();
    final visuals = _layout.toVisualChanges();
    String base;
    if (models.isEmpty) {
      final single = currentContext;
      if (single != null) {
        base = _exporter.export(single);
      } else {
        base = '';
      }
    } else {
      base = _exporter.exportAll(models);
    }
    if (visuals.isNotEmpty) {
      final visualMd = _exporter.exportVisual(visuals);
      if (base.isEmpty) return visualMd;
      return '$base\n\n$visualMd';
    }
    return base;
  }

  void toggleEnabled() {
    if (isEnabled.value) {
      disable();
    } else {
      enable();
    }
  }

  void enable() {
    isEnabled.value = true;
    isExpanded.value = true;
    notifyListeners();
  }

  void disable() {
    isEnabled.value = false;
    isExpanded.value = false;
    selected.value = null;
    hovered.value = null;
    pendingPopupFor.value = null;
    _engine.clear();
    _annotation.clear();
    notifyListeners();
  }

  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
    notifyListeners();
  }

  void expand() {
    isExpanded.value = true;
    notifyListeners();
  }

  void collapse() {
    isExpanded.value = false;
    notifyListeners();
  }

  void togglePause() {
    isPaused.value = !isPaused.value;
    notifyListeners();
  }

  void toggleVisibility() {
    isVisible.value = !isVisible.value;
    notifyListeners();
  }

  void toggleLayout() {
    isLayoutMode.value = !isLayoutMode.value;
    notifyListeners();
  }

  // Called by overlay on hover
  void onHover(Offset globalOffset) {
    if (!isEnabled.value || isPaused.value) return;
    _engine.hoverAt(globalOffset);
  }

  void clearHover() {
    _engine.clearHover();
  }

  // Called on tap (select)
  void selectAt(Offset globalOffset) {
    if (!isEnabled.value || isPaused.value) return;
    final result = _engine.selectAt(globalOffset);
    if (result != null) {
      pendingPopupFor.value = result;
      notifyListeners();
    }
  }

  void addAnnotation(String note) {
    final target = pendingPopupFor.value ?? selected.value;
    if (target == null) return;
    _history.add(target.facts, note);
    pendingPopupFor.value = null;
    // Keep selection for next? Clear pending but keep history
    notifyListeners();
  }

  void cancelPopup() {
    pendingPopupFor.value = null;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void removeEntry(int id) {
    _history.remove(id);
    notifyListeners();
  }

  void _onEngineSelection() {
    if (isEnabled.value) {
      selected.value = _engine.selected.value;
    }
  }

  void _onEngineHover() {
    hovered.value = _engine.hovered.value;
  }

  void _onEngineChange() => notifyListeners();

  @override
  void dispose() {
    _engine.selected.removeListener(_onEngineSelection);
    _engine.hovered.removeListener(_onEngineHover);
    _engine.removeListener(_onEngineChange);
    _layout.removeListener(_onEngineChange);
    _layout.placements.removeListener(_onEngineChange);
    _layout.wireframeOpacity.removeListener(_onEngineChange);
    isEnabled.dispose();
    isExpanded.dispose();
    isPaused.dispose();
    isVisible.dispose();
    isLayoutMode.dispose();
    selected.dispose();
    hovered.dispose();
    pendingPopupFor.dispose();
    _engine.dispose();
    _annotation.dispose();
    _history.dispose();
    _layout.dispose();
    super.dispose();
  }

  // Backwards compat for old ActivationToggle
  void toggle() => toggleEnabled();
  void enableLegacy() => enable();
  void disableLegacy() => disable();
}
