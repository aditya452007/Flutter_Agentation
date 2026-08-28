# Feature Specification: L06 — Annotation System

**Feature Branch**: `L06-annotation`

**Created**: 2026-08-28

**Status**: Draft — depends on L00–L05 (panel placeholder exists, controller exists)

**Input**: `spec.md:FR-008` Developer Feedback + `architecture.md:3.5` Annotation Manager + `context.md:Project Vision` developer intent + `design-statement.md:52-54` Feedback field

## User Scenarios & Testing

### User Story 1 — Attach a textual note to the selected target (Priority: P1)

As the developer after inspecting a widget, I type "Make this button more rounded and slightly taller" into a text field, and the note is held with the current selection so export can include it.

**Why P1**: `spec.md:FR-008` + `problem-statement.md:48-69` — the note is the "developer intent" that bridges visual observation and agent action (`architecture.md:4`).

**Independent Test**: Pump `InfoPanel` with `AnnotationManager`; enter text in `FeedbackField`; assert `manager.currentNote == "Make this button..."` and `ContextModel.intent.note` equals it.

**Acceptance Scenarios**:
1. **Given** a selection present, **When** typing in the feedback field, **Then** `AnnotationManager.value` updates synchronously and `InfoPanel` retains the text when scrolling
2. **Given** no selection (panel shows placeholder), **When** checking feedback field, **Then** it is disabled or shows "Select a widget to annotate" hint

---

### User Story 2 — One annotation per selection (Priority: P1)

As the developer, when I select widget A, type a note, then select widget B, the note for A is preserved with A's context (not silently moved to B), and B starts with an empty note.

**Why P1**: `decisions.md:D-006` — facts vs intent must stay paired to the correct selection; mixing A's intent with B's facts would produce wrong Markdown.

**Independent Test**: Type "Align with right edge" on A → `collector.contextFor(A).intent.note == "Align..."` ; select B → new `ContextModel.intent == null` until typed.

**Acceptance Scenarios**:
1. **Given** A's note exists, **When** selecting B, **Then** `currentNote` resets to `null` (or empty) for B
2. **Given** selecting A again after B, **When** note for A was previously saved, **Then** either A shows cached note (if cache per-target) or empty — **spec choice: empty** in V1 to keep it simple (no per-target cache), noted in Assumptions

---

### User Story 3 — Trimming and capping (Priority: P2)

As the exporter, I want notes trimmed and capped at 2000 chars so Markdown is stable and agents aren't fed 10k-char pastes.

**Why P2**: Stability + readability; huge notes defeat "high-quality actionable context" (`build-instructions.md` goal).

**Independent Test**: Type a 3000-char string → `manager.currentNote.length == 2000` and leading/trailing whitespace stripped.

**Acceptance Scenarios**:
1. **Given** input has leading/trailing whitespace, **When** saved, **Then** stored as `trim()`ed
2. **Given** 2500-char input, **When** saved, **Then** truncated to 2000 with no throw

---

### Edge Cases

- Empty string / only whitespace — treated as `null` intent (no Developer Feedback section in Markdown).
- Very fast typing (rapid `onChanged`) — manager updates via `ValueNotifier` synchronously, no debounce in V1.
- Hot reload — feedback persists in `ValueNotifier` if controller survives; acceptable.

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide `AnnotationManager` class owning `ValueNotifier<DeveloperIntent?> current` (or `ValueNotifier<String?> rawNote`) plus `void setNote(String value)` and `void clear()` and `void bindToSelection(ValueListenable<SelectionResult?> selection)` to reset on selection change.
- **FR-002**: System MUST provide `FeedbackField` widget — a `TextField`/`TextFormField` (multiline, maxLines 3, minLines 1) with hint "Describe the change… (e.g., Make more rounded + taller)" and semantics label "Developer feedback."
- **FR-003**: Feedback field MUST be inserted into `InfoPanel` placeholder (L05) — slot `feedbackSlot` or direct composition — and must be disabled when no selection.
- **FR-004**: Note trimming/capping MUST be done in the manager, not in the widget: `note = value.trim(); if (note.isEmpty) null else note.substring(0, min(2000, length))`.
- **FR-005**: Manager MUST be injectable/`Provider`-less for V1 — constructor `AnnotationManager()` with no external deps, owned by `AgenationController`.
- **FR-006**: `DeveloperIntent` MUST be reuse from L01 (`note: String`) — do not duplicate a second note type.
- **FR-007**: No V2 drawing/rectangle/arrow/freehand in this level — `design-statement.md:116-120` forbids it; `architecture.md:3.5` V2 items remain stubbed as `VisualChanges?` null.

### Key Entities

- **AnnotationManager**: state holder `{ ValueNotifier<DeveloperIntent?> current; void setNote(String); void clear(); }` bound to selection.
- **FeedbackField**: `StatelessWidget/StatefulWidget` wrapping `TextField` + `onChanged: manager.setNote`.
- **DeveloperIntent**: already defined in L01 — `note: String`.

## Success Criteria

- **SC-001**: Widget tests: typing updates manager, empty gives null, 2000-cap, selection change resets — 5+ cases; `flutter analyze` → No issues.
- **SC-002**: `FeedbackField` uses `Theme.of(context).colorScheme` + `TextTheme` — no hardcoded colors; hint visible and accessible.
- **SC-003**: Manual: type note → `ContextModel.intent.note` matches in debugger → L07 exporter includes the note verbatim in Markdown.
- **SC-004**: No `*.freezed.dart` needed; manager is ~40 lines.

## Assumptions

- Per-selection caching is **not** in V1 — selecting a new widget clears the note. If developers request per-target history, it becomes a V1.x ADR (out of spec).
- `maxLength` enforcement is manager-side (substring) with `MaxLengthEnforcement.none` on the field — so Android/iOS paste of >2000 chars still trims predictably.

---

## Technical Design

### Languages & Versions

| Layer | Language | Version |
|-------|----------|---------|
| Manager | Dart 3.12.2 | Pure Dart, `ValueNotifier` |
| Widget | Flutter 3.44.9 | `material.dart` `TextField` |

### Folder Structure

```text
lib/
├── src/
│   ├── context/                  # L01 DeveloperIntent
│   ├── resolver/                 # L02
│   ├── selection/                # L03
│   ├── overlay/                  # L04/L05
│   │   ├── info_panel.dart                # now composes FeedbackField
│   │   └── widgets/feedback_field.dart    # NEW via L06 but lives in annotation or overlay?
│   └── annotation/               # NEW
│       ├── annotation_manager.dart
│       └── developer_note.dart   # re-export L01 type or alias
test/
├── annotation/
│   ├── annotation_manager_test.dart
│   └── feedback_field_test.dart
```

Final placement: manager in `lib/src/annotation/annotation_manager.dart`, widget in `lib/src/annotation/feedback_field.dart` but exported into overlay via barrel — either is fine as long as `lib/agentation.dart` exposes both.

ASCII — binding:

```text
 InfoPanel (L05)
   |
   +-- FeedbackField (L06)
          | text input "Make more rounded..."
          v
   AnnotationManager.setNote(value)
          |  trim + cap 2000
          v
   ValueNotifier<DeveloperIntent?> current = DeveloperIntent(note)
          |
          v
   AgenationController / ContextCollector
          |  reads manager.current when building ContextModel
          v
   ContextModel{ facts, intent: DeveloperIntent(note), visual: null }
          |
          v
   (L07) MarkdownExporter -> includes "> Make more rounded..." block
```

ASCII — selection reset:

```text
SelectionEngine.selected changes (A -> B)
        |
        v
AnnotationManager.bindToSelection(selectedListenable)
        |
        +-- listener: clear() => current.value = null
        |
        +-- FeedbackField (via ValueListenableBuilder) shows empty hint for B
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/src/annotation/annotation_manager.dart` | `AnnotationManager` with `ValueNotifier<DeveloperIntent?>` + `setNote`/`clear`/`bindToSelection` |
| `lib/src/annotation/feedback_field.dart` | `FeedbackField` widget (TextField, hint, maxLines) |
| `lib/src/annotation/index.dart` | Barrel for annotation (optional) |
| `test/annotation/annotation_manager_test.dart` | Trim, empty-null, cap 2000, bind reset |
| `test/annotation/feedback_field_test.dart` | Typing updates, disabled when no selection, semantics |

Also update `lib/src/overlay/info_panel.dart` to mount `FeedbackField` in its placeholder slot and `lib/src/overlay/agentation_controller.dart` to own `AnnotationManager`.

### Classes

| Class | File | Responsibility |
|-------|------|----------------|
| `AnnotationManager` | `annotation_manager.dart` | `ValueNotifier<DeveloperIntent?> current`; `void setNote(String)`; `void clear()`; `void bindToSelection(ValueListenable<SelectionResult?>)`; `void dispose()` |
| `FeedbackField` | `feedback_field.dart` | `const FeedbackField({required AnnotationManager manager, bool enabled})`; stateless/stateful wrapping TextField; `onChanged: manager.setNote` |

### Functions / APIs

```dart
// annotation_manager.dart
class AnnotationManager {
  AnnotationManager();
  ValueNotifier<DeveloperIntent?> get current; // nullable
  void setNote(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) { current.value = null; return; }
    final capped = trimmed.length > 2000 ? trimmed.substring(0, 2000) : trimmed;
    current.value = DeveloperIntent(note: capped);
  }
  void clear() => current.value = null;
  void bindToSelection(ValueListenable<SelectionResult?> selection);
  void dispose();
}

// feedback_field.dart
class FeedbackField extends StatelessWidget {
  const FeedbackField({super.key, required this.manager, this.enabled = true});
  final AnnotationManager manager;
  final bool enabled; // false when no selection
  // uses TextField(controller:..., onChanged: manager.setNote, hintText, semanticsLabel)
}
```

### Design — Instrument aesthetic

- FeedbackField is a quiet M3 `TextField` with `filled: true, fillColor: surfaceContainerLow`, 12 radius, no decorative background — matches panel. Hint in `onSurfaceVariant` Inter 400. No gradients, no mesh per your anti-AI-slop rule.
- Motion: `AnimatedSwitcher` between enabled/disabled, `disableAnimations` disables.

### Differentiation

- `Pintap`/`Flan` annotations bundle drawing + text together; this V1 keeps **text-only** (`design-statement.md:116-120`), preserving the seam for V2 rectangle/arrow without requiring the drawing engine now.

### Testing & Analyze Notes

- Run `flutter analyze` → No issues; `flutter test test/annotation/` → 5+.
- Verify `InfoPanel` integration: pump full panel + manager + type → `manager.current?.note ==` typed string.

### How to verify

```ps
flutter analyze
flutter test test/annotation/annotation_manager_test.dart
```

