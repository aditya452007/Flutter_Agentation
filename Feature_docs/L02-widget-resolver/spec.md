# Feature Specification: L02 — Widget Resolver

**Feature Branch**: `L02-widget-resolver`

**Created**: 2026-08-28

**Status**: Draft — depends on L00 + L01 (needs ContextModel + toolchain)

**Input**: `architecture.md:3.3` Widget Resolver + `architecture.md:39-55` Source Location + `spec.md:FR-004–FR-007` + `decisions.md:D-006/ADR-009` (optional source) + study of `WidgetInspector` / `Element` / `RenderObject` (see build-instructions recon)

## User Scenarios & Testing

### User Story 1 — Resolve widget identity + source + bounds + hierarchy from an Element (Priority: P1)

As the `SelectionEngine`, after hit-testing an `Element`, I want `WidgetResolver.resolve(element)` to return a `WidgetFacts` ready to wrap into `ContextModel`, so the collector doesn't re-derive widget introspection.

**Why P1**: Core of V1 — without a resolver, selection is just a coordinate with no context (`spec.md:FR-004–FR-007`).

**Independent Test**: In a widget test, pump a `Card > ElevatedButton("Get Started")` tree, find the button `Element`, call `resolver.resolve(element)` → assert `widgetType` contains `ElevatedButton`, `text=="Get Started"`, `hierarchy` ends with `ElevatedButton`, `bounds.width >0`.

**Acceptance Scenarios**:
1. **Given** an `ElevatedButton` element in a pumped tree, **When** `resolver.resolve(element)`, **Then** `widgetType`/`runtimeType` match and `text` is extracted
2. **Given** a deeply nested widget (5+ ancestors), **When** `hierarchy` is returned, **Then** it is root→leaf, bounded to 12 entries (see L01)

---

### User Story 2 — Source location is optional, never fabricated (Priority: P1)

As the panel/exporter, I want `sourceLocation: SourceLocation?` to be `null` in release or for framework widgets, so UI can render "Source unavailable in this build" rather than a lie.

**Why P1**: `spec.md:FR-005` + `architecture.md:39` + `decision.md:ADR-009` — fabricating breaks trust.

**Independent Test**: Resolve a framework-owned widget (e.g., `RenderFlex`) in a test build where `WidgetInspector` cannot provide a location → `sourceLocation == null`; separately resolve a user `const MyWidget()` where `creationLocation` is available → non-null.

**Acceptance Scenarios**:
1. **Given** a framework widget with no creation location, **When** `resolver.resolve(frameworkElement)`, **Then** `sourceLocation == null`
2. **Given** a host app widget compiled with debug info, **When** resolved, **Then** `sourceLocation.file.endsWith(".dart") && line>0`

---

### User Story 3 — Bounds are derived from RenderObject, not guesswork (Priority: P1)

As the overlay, I need `RectInfo` in global coordinates to draw the highlight precisely.

**Why P1**: `spec.md:FR-006` + `design-statement.md:38-41` — highlight must be precise.

**Independent Test**: Pump a 320×52 button at known offset → `resolver.bounds` matches `RenderBox.localToGlobal(Offset.zero) & size` within 0.5px.

**Acceptance Scenarios**:
1. **Given** a `RenderBox` element with a known `localToGlobal` offset, **When** `BoundsExtractor.rect(element)`, **Then** `RectInfo` matches
2. **Given** an element whose `RenderObject` is not a `RenderBox` (e.g., `RenderView`), **When** bounds requested, **Then** `null` is returned gracefully (no throw)

---

### Edge Cases

- Release build / obfuscated `runtimeType` — still return `widgetType` string; source null.
- `Element` whose widget is `null` (defunct) — return `null` or fallback object, never crash.
- Very large hierarchy (>12) — truncate to nearest 12 ancestors with `…` sentinel; `spec.md:FR-007` says hierarchy should be bounded.
- Missing `text` — many widgets have no textual property; `text == null` is valid; maybe extract from `Text` descendant or `semanticsLabel`.

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide `WidgetResolver` class with `WidgetFacts resolve(BuildContext context, Element element)` (or `resolveElement(Element element)` if context not needed) as the primary entry.
- **FR-002**: Resolver MUST delegate sub-concerns to small helpers: `SourceResolver.location(Element) → SourceLocation?`, `BoundsExtractor.rect(Element) → RectInfo?`, `HierarchyExtractor.path(Element) → List<String>`, `TextExtractor.text(Element) → String?`, `KeyResolver.key(Element) → String?` — each testable in isolation.
- **FR-003**: Source location MUST use Flutter-supported inspection facilities (`WidgetInspector`/`creationLocation`/`_location` debug API) where available; MUST treat absence as `null`, not error, and log no warnings in release.
- **FR-004**: Bounds MUST use `RenderObject` → `(element.renderObject as RenderBox).localToGlobal(Offset.zero) & size` when `renderObject is RenderBox`; MUST return `null` for non-box or unmounted ROs.
- **FR-005**: Hierarchy MUST walk `element.visitAncestorElements` (or `element.debugGetDiagnosticChain` filtered) and collect ancestor `widget.runtimeType` names; MUST cap at 12 entries and order root→leaf.
- **FR-006**: Resolver MUST handle deeply nested trees (>100 widgets) without stack overflow (iterative walk, not recursion depth risk).
- **FR-007**: All extractions MUST be `O(depth)` and synchronous — no `Future` in V1 — so selection feels instant (`spec.md:Performance`).
- **FR-008**: Resolver MUST distinguish: `widgetType` = user-declared type (may be `StatefulWidget`), `runtimeType` = concrete `widget.runtimeType.toString()` — both strings, both optional? At least one non-empty.

### Key Entities

- **WidgetResolver**: facade — delegates to Extractors, returns `WidgetFacts`.
- **SourceResolver**: `SourceLocation?` extraction.
- **BoundsExtractor**: `RectInfo?` from `RenderObject`.
- **HierarchyExtractor**: bounded `List<String>` of ancestor types.
- **TextExtractor / KeyResolver**: small helpers for `WidgetFacts.text` and `key`.

## Success Criteria

- **SC-001**: Widget tests cover: (a) user widget with text + source available, (b) framework widget source-null, (c) non-RenderBox bounds-null, (d) deep hierarchy truncation, (e) defunct element graceful.
- **SC-002**: `flutter test test/widget_resolver_test.dart` passes with ≥8 cases; `flutter analyze` → No issues.
- **SC-003**: No throw on `null` element, bad RenderObject, or missing source — resolver always returns a `WidgetFacts` (with `sourceLocation==null` as needed).
- **SC-004**: Resolver output feeds L03 without adapter — `SelectionEngine` can directly call `WidgetResolver.resolve()`.

## Assumptions

- Flutter's debug creation locations are available when `kDebugMode` and host code is not obfuscated; tests may run in debug profile so source is usually available for `const` widgets pumped in tests.
- `RenderBox` is the common RO — `RenderView`/`RenderParagraph` edge cases return `null` bounds which the overlay handles as "no highlight."

---

## Technical Design

### Languages & Versions

| Layer | Language | Version |
|-------|----------|---------|
| Resolver | Dart 3.12.2 / Flutter 3.44.9 | Pure Dart + `package:flutter/widgets.dart`, `rendering.dart` |
| Tests | `flutter_test` | Golden not required in this level (bounds numeric) |

### Folder Structure

```text
lib/
├── src/
│   ├── context/                  # L01 models (ContextModel, SourceLocation etc.)
│   └── resolver/                 # NEW in this level
│       ├── widget_resolver.dart  # WidgetResolver facade
│       ├── source_resolver.dart  # SourceResolver
│       ├── bounds_extractor.dart # BoundsExtractor
│       ├── hierarchy_extractor.dart
│       ├── text_extractor.dart
│       └── key_resolver.dart
test/
├── resolver/
│   ├── widget_resolver_test.dart
│   ├── source_resolver_test.dart
│   ├── bounds_extractor_test.dart
│   └── hierarchy_extractor_test.dart
```

ASCII — delegation:

```text
  SelectionEngine
        |
        v
  WidgetResolver.resolve(element)
        |
   +----+------+-------+--------+------+
   |       |       |       |        |
 Source  Bounds Hierarchy Text   Key
 Resolver Extract  Extract Extract Resolver
   |       |       |       |        |
   +-------+-------+-------+--------+
                 |
          WidgetFacts  (to L01 ContextModel)
```

ASCII — Element walk:

```text
Element (target ElevatedButton)
   ^  visitAncestorElements / debugChain
   |
   Card  -- Scaffold -- Column -- Container -- ...
   |       (reverse so root -> leaf)
   v
Hierarchy = ["Scaffold","Column","Card","ElevatedButton"]  (cap 12)
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/src/resolver/widget_resolver.dart` | Facade `WidgetResolver` |
| `lib/src/resolver/source_resolver.dart` | `SourceResolver.location(Element)` |
| `lib/src/resolver/bounds_extractor.dart` | `BoundsExtractor.rect(Element)` |
| `lib/src/resolver/hierarchy_extractor.dart` | `HierarchyExtractor.path(Element)` |
| `lib/src/resolver/text_extractor.dart` | `TextExtractor.text(Element)` (look for `Text` widget descendant / semantics) |
| `lib/src/resolver/key_resolver.dart` | `KeyResolver.stringOf(Element)` |
| `test/resolver/*_test.dart` | Unit + widget tests per extractor |

Also update `lib/agentation.dart` barrel to re-export resolver types if public; keep `src/` private otherwise.

### Classes

| Class | File | Responsibility |
|-------|------|----------------|
| `WidgetResolver` | `widget_resolver.dart` | Orchestrates sub-extractors; `WidgetFacts resolve(Element e)`; injects dependencies for testability |
| `SourceResolver` | `source_resolver.dart` | `SourceLocation? location(Element)`; uses `WidgetInspector` debug APIs; returns `null` when unavailable |
| `BoundsExtractor` | `bounds_extractor.dart` | `RectInfo? rect(Element)` via `RenderBox.localToGlobal` |
| `HierarchyExtractor` | `hierarchy_extractor.dart` | `List<String> path(Element)` capped 12 |
| `TextExtractor` | `text_extractor.dart` | `String? text(Element)` — searches `Text` child or `Semantics` |
| `KeyResolver` | `key_resolver.dart` | `String? keyOf(Element)` via `widget.key.toString()` |

### Functions / APIs

```dart
// widget_resolver.dart
class WidgetResolver {
  const WidgetResolver({
    SourceResolver? source,
    BoundsExtractor? bounds,
    HierarchyExtractor? hierarchy,
    TextExtractor? text,
    KeyResolver? key,
  });
  WidgetFacts resolve(Element element);
}

// source_resolver.dart
class SourceResolver {
  SourceLocation? location(Element element);
}

// bounds_extractor.dart
class BoundsExtractor {
  RectInfo? rect(Element element);
  SizeInfo? size(Element element);
}

// hierarchy_extractor.dart
class HierarchyExtractor {
  List<String> path(Element element, {int maxDepth = 12});
}

// tex/key resolvers
class TextExtractor { String? text(Element element); }
class KeyResolver { String? keyOf(Element element); }
```

### Design Notes

- **No AI slop**: resolver is pure logic — no UI — but future highlight will be a thin M3 stroke, not a decorative fill (see L04).

### Differentiation

- `Flan` reimplements aspects of hit-testing/bounds; this resolver **delegates to `RenderBox` APIs** and isolates platform quirks behind `BoundsExtractor` per `architecture.md:87-93`, minimizing fork debt.

### Testing & Analyze Notes

- Run `flutter test test/resolver/` + `flutter analyze` (must stay green).
- Mock `Element` via real pumped widgets rather than mocks — representative tests per `architecture.md:Testing Strategy`.

### How to verify

```ps
flutter analyze        # No issues
flutter test test/resolver/widget_resolver_test.dart  # 8+ cases green
```

