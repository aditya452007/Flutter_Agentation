import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/selection/selection_result.dart';

class AnnotationManager extends ChangeNotifier {
  AnnotationManager();

  final ValueNotifier<DeveloperIntent?> current = ValueNotifier<DeveloperIntent?>(null);

  void setNote(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      current.value = null;
      notifyListeners();
      return;
    }
    final capped = trimmed.length > 2000 ? trimmed.substring(0, 2000) : trimmed;
    current.value = DeveloperIntent(note: capped);
    notifyListeners();
  }

  void clear() {
    current.value = null;
    notifyListeners();
  }

  void bindToSelection(ValueListenable<SelectionResult?> selection) {
    selection.addListener(_onSelectionChanged);
    // store reference for dispose? For V1 we keep simple and not remove unless dispose.
    _selection = selection;
  }

  ValueListenable<SelectionResult?>? _selection;

  void _onSelectionChanged() {
    clear();
  }

  @override
  void dispose() {
    if (_selection != null) {
      _selection!.removeListener(_onSelectionChanged);
    }
    current.dispose();
    super.dispose();
  }
}
