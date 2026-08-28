# Feature Specification: L09 — Hardening & V1 GA Polish

**Feature Branch**: `L09-hardening`

**Created**: 2026-08-28

**Status**: Draft — depends on L00–L08 (all V1 modules exist, audit fixes applied)

**Input**: Audit `Feature_docs/AUDIT_V1_HARDENING.md:1` Bugs #1–#7 + Subtle S-1..S-8 + `context/architecture.md` invariants

## User Scenarios & Testing

### User Story 1 — Source is available in debug (Priority: P1)

As the developer inspecting a `const` widget, I see `Source: lib/screens/home.dart:143:12` not “unavailable”, while framework widgets still show unavailable gracefully.

**Acceptance**: Pump `const Text('hi')` in test → `SourceResolver.location` returns non-null with `file.contains('lib/')`; pump `Scaffold` → returns null without throw.

### User Story 2 — Hierarchy is developer-relevant (Priority: P1)

As the agent reading Markdown, I see `Scaffold → Column → Card → ElevatedButton ◄ selected` not 20 private `Semantics _InkResponseStateWidget` entries.

**Acceptance**: Selecting `Text('front')` inside `ElevatedButton` yields hierarchy containing `ElevatedButton` and not containing `_RawViewInternal`; length ≤20.

### User Story 3 — Copy-paste is end-to-end (Priority: P1)

As the developer, I enable Inspect → tap button → type note → tap Copy → paste into editor → Markdown is deterministic, hierarchy not duplicated, note escaped, and “Copied” toast appears.

**Acceptance**: `MarkdownExporter` snapshot test with full model matches goldens exactly; `CopyButton` widget test with `FakeClipboardService` passes.

## Requirements

- **FR-001**: `SourceResolver` must read `_location` via dynamic `_location` + normalize `file://` → `lib/` and never leak absolute paths.
- **FR-002**: `HierarchyExtractor` must filter private (`_`) and noisy (`Semantics`, `Listener` etc.) and cap at 20, always keeping leaf.
- **FR-003**: `SelectionEngine` must lift from `Text` leaf to nearest `Button/Card/Tile` ancestor when leaf is text, using bounds containment.
- **FR-004**: `MarkdownExporter` must render hierarchy once (tree view only) and escape `` ``` `` + leading `#`.
- **FR-005**: `AgentationOverlay` must show `InfoPanel` + `FeedbackField` + `CopyButton` wired via `AgentationController.annotation`/`currentContext`; highlight must not drift on scroll (recompute on metrics change).
- **FR-006**: `flutter analyze` No issues, `flutter test` 45+ green, `example` builds web.

## Key Entities

- `SourceResolver`, `HierarchyExtractor`, `SelectionEngine`, `MarkdownExporter`, `AgentationOverlay`, `AgentationController`.

## Success Criteria

- **SC-001**: `flutter analyze` (root + example) No issues.
- **SC-002**: `flutter test` 45 passed, including 4 markdown snapshot cases.
- **SC-003**: Manual demo on Web + one desktop: Inspect → button → note → Copy → paste shows all 7 Markdown sections once.

## Assumptions

- V1 still has no network/AI/MCP; screenshot remains boolean flag.

---

## Technical Design

### Languages

Dart 3.12.2 / Flutter 3.44.9

### Folder Structure

```text
lib/src/resolver/source_resolver.dart   # _location + normalize
lib/src/resolver/hierarchy_extractor.dart # filter + cap 20
lib/src/selection/selection_engine.dart  # lift Text→Button
lib/src/exporter/markdown_exporter.dart # dedup + escape
lib/src/overlay/agentation_overlay.dart # InfoPanel + Feedback + Copy wiring
```

### Files, Classes, Functions

Same as V1 L01–L08, no new files — hardening is edits + tests.

### Design — Instrument

No visual change — panel remains M3 neutral, highlight 1.5px, no gradients.

### Testing

Add `test/exporter/markdown_exporter_test.dart` already done (7 cases); add `test/resolver/source_resolver_test.dart` for debug file path and `test/hierarchy_filter_test.dart`.
