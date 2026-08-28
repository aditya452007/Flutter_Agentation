# Feature Specification: L01 — Core Context Models

**Feature Branch**: `L01-core-models`

**Created**: 2026-08-28

**Status**: Draft — depends on L00 (toolchain must be green before models)

**Input**: `architecture.md:3.4` Context Collector + `architecture.md:4` Context Model (facts/intent/visual separation) + `decisions.md:D-006/D-010` + `spec.md` Suggested Output + `problem-statement.md:48-69`

## User Scenarios & Testing

### User Story 1 — Single source of truth for all V1 outputs (Priority: P1)

As the future `MarkdownExporter` and `MCP adapter (V3)`, I want one immutable `ContextModel` that holds everything the resolver observed plus the developer's note, so Markdown and JSON are just two renderings of the same facts.

**Why P1**: `decisions.md:D-011` + `architecture.md:83-311` require one model, two adapters — not two inspection paths. If this model is wrong, every later level breaks.

**Independent Test**: Construct a `ContextModel` in a unit test with a fake `SourceLocation` + bounds + hierarchy, round-trip it via `toJson`/`fromJson`, assert equality.

**Acceptance Scenarios**:
1. **Given** a `ContextModel` with `sourceLocationAvailable: true`, **When** `toJson() → fromJson()`, **Then** all fields equal
2. **Given** a model with `visualChanges: null` (V1), **When** `toMarkdown()`, **Then** the visual section is omitted (not fabricated)

---

### User Story 2 — Handle unavailable metadata gracefully (Priority: P1)

As the `WidgetResolver` (next level), I want to be able to set `sourceLocation: null` or `bounds: null` and still have a valid model, so `spec.md:FR-005` acceptance ("graceful behavior when source unavailable") is satisfiable.

**Why P1**: `architecture.md:118` — not every field is guaranteed for every widget/platform/build mode.

**Independent Test**: Construct `ContextModel(sourceLocation: null, bounds: null)` → `validate()` passes → exporter branch renders "Source unavailable".

**Acceptance Scenarios**:
1. **Given** `sourceLocation == null`, **When** `markdownExporter.export(model)`, **Then** output contains `Source unavailable in this build` not a fabricated path
2. **Given** `bounds == null`, **When** collecting geometry, **Then** model still exports hierarchy + widget type

---

### User Story 3 — Facts vs intent vs visual stays separated (Priority: P2)

As a developer reading Markdown, I want to distinguish "the tool observed `x: 100→140`" from "the developer wrote *Align with right edge*" so the agent knows which is fact.

**Why P2**: `decisions.md:D-006` + `design-statement.md:99-113` forbid conflating observed geometry with semantic intent.

**Independent Test**: Create `ContextModel(facts: {...}, intent: DeveloperNote("Align..."), visualChanges: null)` → assert `facts`, `intent`, `visual` are distinct top-level keys in JSON.

**Acceptance Scenarios**:
1. **Given** a model with only `facts` and `intent`, **When** serialized, **Then** JSON has exactly `facts`/`intent`/`visual` (visual null) — no merged `description` field

---

### Edge Cases

- Extremely deep hierarchy (>50 ancestors) — model stores bounded `List<String>` capped at 12 (see FR-003) to avoid huge outputs (`spec.md:FR-007`).
- Empty text / missing key / missing semantics — all fields nullable; `toString()` must not throw.
- V2 fields (`visualChanges`) present in V1 — model allows them as `VisualChanges?` stub but exporter ignores them unless a V2 flag is set.

## Requirements

### Functional Requirements

- **FR-001**: System MUST define `SourceLocation{ String file; int line; int column; }` as an immutable value object with `copyWith`, `==`, `toJson`/`fromJson`, `toString() == "file:line:column"`.
- **FR-002**: System MUST define `ContextModel` with: `WidgetFacts facts`, `DeveloperIntent? intent`, `VisualChanges? visual` — three top-level buckets — plus convenience `sourceLocationAvailable: bool` derived from `facts.sourceLocation != null`.
- **FR-003**: `WidgetFacts` MUST contain at least: `widgetType: String`, `runtimeType: String`, `key: String?`, `text: String?`, `sourceLocation: SourceLocation?`, `bounds: RectInfo?`, `size: SizeInfo?`, `hierarchy: List<String>` (bounded, max 12, root→leaf), `semantics: String?`, `properties: Map<String,String>?`. All optional except `widgetType`/`runtimeType`.
- **FR-004**: `RectInfo`/`SizeInfo` MUST wrap `Rect`/`Size` as serializable primitives `{x,y,width,height}` / `{width,height}` with `toJson`/`fromJson`.
- **FR-005**: `DeveloperIntent` MUST be a single `note: String` (trimmed, max 2000 chars) — V1 textual annotation only (`spec.md:FR-008`, `design-statement.md:03`).
- **FR-006**: `VisualChanges` MUST exist as a **stub type** (empty sealed class or typedef) with a doc comment "V2 only — not used in V1" so later levels can extend without breaking the model (`architecture.md:67-82`).
- **FR-007**: All models MUST be `@immutable`, have `const` constructors where possible, override `==`/`hashCode`, and be covered by unit tests. Prefer manual `copyWith` + `toJson` in L01 to avoid `freezed` codegen until L02+ (keeps deps minimal per `build-instructions.md:155`).
- **FR-008**: Models MUST serialize deterministically — same input always produces same JSON key order — so Markdown snapshots are stable (`architecture.md:196-198`).
- **FR-009**: No AI, network, or platform imports in this level — pure Dart/Flutter (`spec.md:FR-012/013`).

### Key Entities

- **SourceLocation**: file/line/column triple; nullable to represent unavailable.
- **WidgetFacts**: observed runtime truths — widget identity, source, geometry, hierarchy, text/key/semantics.
- **DeveloperIntent**: authored feedback — the developer's free-text note.
- **VisualChanges (V2 stub)**: placeholder for `width 120→160` etc. — present as type but always `null` in V1.
- **ContextModel**: aggregate root — `ContextModel{ facts, intent, visual }` plus `toJson`/`fromJson` and `isSourceAvailable` helper.

## Success Criteria

- **SC-001**: `dart test test/context_model_test.dart` passes with 6+ cases: full model, source-null, bounds-null, hierarchy-capped, intent-trimmed, JSON round-trip.
- **SC-002**: `flutter analyze` remains `No issues found!` after adding models (very_good_analysis strict).
- **SC-003**: A model with `sourceLocation: null` exports Markdown containing "Source unavailable" (verified by L07 but model must support the branch).
- **SC-004**: No `*.freezed.dart` or `*.g.dart` is required — L01 uses hand-written codegen so `.gitignore:12-13` stays clean.

## Assumptions

- `freezed` + `json_serializable` are **not** used in L01 to keep the level tiny and dependency-free; a later ADR may introduce them if models grow (that would generate `*.freezed.dart`/`*.g.dart` which are gitignored and analyzer-excluded).
- Hierarchy strings are widget type names (`Scaffold`, `Column`, `Card`) — not full `Element` dumps — to keep Markdown stable.

---

## Technical Design

### Languages & Versions

| Layer | Language | Version |
|-------|----------|---------|
| Models | Dart | 3.12.2 (latest), Flutter 3.44.9 SDK |
| Tests | Dart | `flutter_test` |

### Folder Structure

```text
lib/
├── src/
│   ├── context/
│   │   ├── context_model.dart           # ContextModel + WidgetFacts + DeveloperIntent
│   │   ├── source_location.dart         # SourceLocation
│   │   ├── geometry.dart                # RectInfo / SizeInfo
│   │   └── visual_changes.dart          # VisualChanges stub (V2)
│   └── core/
│       └── types.dart                   # (shared typedefs if needed)
├── agentation.dart                      # barrel re-exports L01 types (public API start)
test/
├── context_model_test.dart
├── source_location_test.dart
└── geometry_test.dart

Feature_docs/L01-core-models/spec.md      # this file
```

ASCII — model composition:

```text
           ContextModel  (single source of truth)
          /      |      \
         /       |       \
   WidgetFacts  DeveloperIntent  VisualChanges? (V2 stub)
   / | | | \        |
  |  | | |  +--> note: String
  |  | | +-----> hierarchy: List<String> (max 12)
  |  | +-------> bounds: RectInfo?  size: SizeInfo?
  |  +---------> sourceLocation: SourceLocation? (null => unavailable)
  +------------> widgetType, runtimeType, key?, text?, semantics?, properties?
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/src/context/context_model.dart` | `ContextModel` + `WidgetFacts` + `DeveloperIntent` |
| `lib/src/context/source_location.dart` | `SourceLocation` |
| `lib/src/context/geometry.dart` | `RectInfo` / `SizeInfo` helpers (wraps `dart:ui` Rect/Size) |
| `lib/src/context/visual_changes.dart` | `VisualChanges` stub type (empty) |
| `lib/agentation.dart` | Public barrel `export 'src/context/context_model.dart'` etc. |
| `test/context_model_test.dart` | JSON round-trip, unavailable, hierarchy cap, intent trim |
| `test/source_location_test.dart` | Equality, toString, json |
| `test/geometry_test.dart` | RectInfo/SizeInfo json/equality |

### Classes

| Class | File | Responsibility |
|-------|------|----------------|
| `SourceLocation` | `source_location.dart` | Immutable `file/line/column`; `toJson`/`fromJson`; `toString() => "$file:$line:$column"` |
| `RectInfo` | `geometry.dart` | `{x,y,width,height}` from `Rect`; `Rect toRect()` helper |
| `SizeInfo` | `geometry.dart` | `{width,height}` from `Size` |
| `WidgetFacts` | `context_model.dart` | Observed facts bucket — see FR-003 fields |
| `DeveloperIntent` | `context_model.dart` | `note` holder; `trimAndCap()` |
| `VisualChanges` | `visual_changes.dart` | `abstract final class VisualChanges` — no fields in V1 |
| `ContextModel` | `context_model.dart` | Root — `{facts, intent, visual}`; `bool get isSourceAvailable`; `Map<String,dynamic> toJson()`; `factory fromJson()` |

### Functions / APIs

```dart
// source_location.dart
const SourceLocation({required String file, required int line, required int column});
Map<String,dynamic> toJson();
factory SourceLocation.fromJson(Map<String,dynamic> json);
String toString();

// geometry.dart
const RectInfo({required double x, y, width, height});
factory RectInfo.fromRect(Rect r);
Rect toRect();
Map<String,dynamic> toJson();

// context_model.dart
const WidgetFacts({required widgetType, required runtimeType, sourceLocation, bounds, hierarchy, ...});
const ContextModel({required WidgetFacts facts, DeveloperIntent? intent, VisualChanges? visual});
bool get isSourceAvailable;
Map<String,dynamic> toJson();
factory ContextModel.fromJson(Map<String,dynamic> json);
ContextModel copyWith({WidgetFacts? facts, DeveloperIntent? intent, VisualChanges? visual});
```

### Design — Instrument aesthetic (not yet UI)

- Models have no UI — design principle here is **determinism and boundedness**: hierarchy capped, note trimmed, no fabricating unavailable fields.

### Differentiation from existing tools

- `Widgetation` exposes hierarchical JSON but mixes facts+intent; this model **separates** them (`decisions.md:D-006`) so V1 Markdown and V3 MCP never conflate observed `x: +40` with semantic intent.

### Testing & Analyze Notes

- Run `flutter analyze` → No issues; `dart test` / `flutter test` → 6+ model tests green.
- No generated files — `flutter analyze` exclusions still required but unused.
- Next level L02 will consume these models in `WidgetResolver`.

