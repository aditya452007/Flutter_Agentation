import 'package:flutter/foundation.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';

/// Single annotation entry — an id + facts + note.
@immutable
class AnnotationEntry {
  const AnnotationEntry({
    required this.id,
    required this.facts,
    required this.note,
  });

  final int id;
  final WidgetFacts facts;
  final String note;

  ContextModel toContextModel() => ContextModel(
        facts: facts,
        intent: DeveloperIntent(note: note),
      );

  AnnotationEntry copyWith({int? id, WidgetFacts? facts, String? note}) =>
      AnnotationEntry(
        id: id ?? this.id,
        facts: facts ?? this.facts,
        note: note ?? this.note,
      );
}

/// In-memory history of multiple annotations with reindex on delete.
class AnnotationHistory extends ChangeNotifier {
  AnnotationHistory();

  final ValueNotifier<List<AnnotationEntry>> entries =
      ValueNotifier<List<AnnotationEntry>>(<AnnotationEntry>[]);

  int get length => entries.value.length;
  bool get isEmpty => entries.value.isEmpty;

  /// Adds a new entry from current selection facts + note. Returns the entry.
  AnnotationEntry add(WidgetFacts facts, String note) {
    final trimmed = note.trim();
    final capped = trimmed.length > 2000 ? trimmed.substring(0, 2000) : trimmed;
    if (capped.isEmpty) return entries.value.last; // shouldn't happen
    final entry = AnnotationEntry(
      id: entries.value.length + 1,
      facts: facts,
      note: capped,
    );
    entries.value = List<AnnotationEntry>.from(entries.value)..add(entry);
    notifyListeners();
    return entry;
  }

  /// Deletes by id and reindexes remaining (1..n).
  void remove(int id) {
    final filtered = entries.value.where((e) => e.id != id).toList();
    // Reindex
    final reindexed = <AnnotationEntry>[];
    for (var i = 0; i < filtered.length; i++) {
      reindexed.add(filtered[i].copyWith(id: i + 1));
    }
    entries.value = reindexed;
    notifyListeners();
  }

  void clear() {
    entries.value = <AnnotationEntry>[];
    notifyListeners();
  }

  List<ContextModel> toContextModels() =>
      entries.value.map((e) => e.toContextModel()).toList();

  @override
  void dispose() {
    entries.dispose();
    super.dispose();
  }
}
