# Progress Tracker — Flutter Agentation

## Current Phase

**Phase 4 — R10 Polish (IN PROGRESS) — Blackout theme, draggable fix, hover blue, Enter handling**
**Previous: L00–L09 + R10 circle→pill + hover + minimal history (COMPLETE, 49 tests green)**

V1 scope: `spec.md:FR-001–FR-014` + `build-instructions.md` V1 Inspect Mode. No V2 visual manipulation or V3 MCP in implementation (seams only). Latest Flutter 3.44.9 / Dart 3.12.2.

## Current Goal — Blackout & UX Polish (your latest feedback)

1. **Blackout visibility**: entire Agentation chrome (circle, pill, hover border, popup, history sheet) to **black** with **pure white icons/text** for maximum contrast — no `surfaceContainerHigh` blending.
2. **Draggable fix**: default bottom-right `16,16 SafeArea` was not ideal, drag vs tap conflict prevented button clicks. Fix: drag only via left handle, tap vs pan threshold 6px, auto-dock to 12px peek, persisted via `SharedPreferences` (or in-memory if unavailable).
3. **Hover**: `MouseRegion` hover border now **indigo/blue** (`#3B82F6` / `Colors.indigo`) 1.5px solid + name badge, not `primary` grey — more visible per your “blue/indigo kind”.
4. **Enter handling**: `FeedbackPopup` TextField `onSubmitted` + `onEditingComplete` must create annotation on **Enter** — already `onSubmitted` exists, but need `textInputAction: done` + `Autofill`? + test. Popup itself in black (`surface: Colors.black` / `surfaceContainerHigh`? → black).
5. **Checklist**: enumerate all Agentation features vs implemented, fill gaps (text selection, multi-select, area, pause, visibility, layout mode, computed styles, React detection modes, shortcuts, screenshot, MCP) — see `Feature_docs/AUDIT_V1_HARDENING.md:7` and new `Feature_docs/CHECKLIST.md`.
6. **Docs sync**: update `progress-tracker.md` (this file), `decision.md` (ADR-017 blackout), `flow.md` (new circle→pill + hover + popup + history flows).

## Completed (since last push `1c238e5`)

- **R10 circle→pill**: `lib/src/overlay/circle_toggle.dart:1` 40dp `smart_toy_outlined` + badge, `lib/src/overlay/pill_toolbar.dart:1` full toolbar Copy/Clear/Pause/Visibility/History/Close, morph 220ms, `lib/src/overlay/agentation_overlay.dart:9` draggable `_dragOffset` + `_autoDock()` 12px peek.
- **Hover**: `lib/src/selection/selection_engine.dart:9` added `hovered` `ValueNotifier` + `hoverAt()` + `clearHover()`, smallest-area heuristic (like `flutter_widget_inspector`) vs deepest depth, lifts `Text` leaf to `Button/Card/Tile`, `MouseRegion.onHover` in overlay, hover border `primary 0.6` + badge.
- **Popup minimal**: `lib/src/annotation/feedback_popup.dart:1` 300×120 `Say what to change…` + `Add`/`Cancel` anchored to selection rect (flip), `lib/src/annotation/annotation_history.dart:1` in-memory `add/remove/clear` reindex, `MarkdownExporter.exportAll()` at `lib/src/exporter/markdown_exporter.dart:88`, `AgentationController` now owns `isExpanded/isPaused/isVisible/pendingPopupFor/history`.
- **Overlay wiring**: info panel + feedback + copy inside bottom sheet (`agentation_overlay.dart:89`), `Directionality` fallback for outside `MaterialApp`, `SelectionHighlight` `IgnorePointer` inside `Positioned` fix.
- **Tests**: `test/overlay/activation_toggle_test.dart:1` 4 tests for circle→pill + hover+popup (49 tests green), `flutter analyze` No issues, `example` builds web (54s) + windows (68s).
- **Spec**: `Feature_docs/R10-circle-hover-history/spec.md:1` drafted from Next.js investigation (`agentation.com` circle→pill, hover, text/area/multi-select, pause, layout mode, marker types) + Flutter packages (`flutter_widget_inspector` smallest-area, `zero_inspector_kit` auto-dock peek).

## Next Up (exact order — small & working)

1. **Blackout theme** — change `CircleToggle` bg `primary` → `Colors.black`, icon `Colors.white`; `PillToolbar` `surfaceContainerHigh` → `Colors.black`, all icons/text `Colors.white`/`white70`; `FeedbackPopup` `surfaceContainerHigh` → `Colors.black` + white hint; hover border `primary 0.6` → `Colors.blue`/`indigo 0.6` + `indigo` badge.
2. **Draggable fix** — restrict drag to handle (left logo area) via `GestureDetector` on handle only, threshold 6px to distinguish tap vs pan, default position `right:16,bottom:24` (not 16,16) + `SafeArea`, persist to `SharedPreferences` key `agnetation_pos`.
3. **Enter handling** — ensure `FeedbackPopup` `TextField` `textInputAction: TextInputAction.done` + `onSubmitted` creates `history.add` and closes popup; test `tester.testTextInput.receiveAction(TextInputAction.done)`.
4. **Hover blue** — change hover decoration `primary` → `Color(0xFF3B82F6)` or `Colors.indigo` with 0.6 alpha + badge `indigo`.
5. **Checklist** — create `Feature_docs/CHECKLIST.md` (Implemented: circle, pill, hover, popup, history, copy, smallest-area, draggable, pause/visibility stubs — Missing: text selection, multi-select, area, animation pause real, layout mode, computed styles, React forensic, shortcuts, screenshots, MCP sync, dark/light persist, per-page 7d storage, etc. + proposal).
6. **Verify** — `flutter analyze` (root+example), `flutter test` (49+), rebuild windows (`example\build\windows\x64\runner\Release\example.exe`).

## Open Questions (Resolved 2026-08-28)

- Q1 Circle logo smart_toy+badge — **RESOLVED: smart_toy+badge** per your R10 answer.
- Q2 Pill full toolbar — **RESOLVED: Full toolbar** (Copy/Clear/Pause/Visibility/History).
- Q3 Draggable peek — **RESOLVED: Yes draggable** with 12px peek.
- Q4 Hover solid+badge — **RESOLVED: Solid+badge** (now changing to blue/indigo per new feedback).
- Q5 Smallest-area — **RESOLVED: Smallest-area** with `_` private filter.
- Q6 History in-memory — **RESOLVED: In-memory** for R10.
- Q7 Blackout — **NEW**: Black chrome + white icons + blue hover + Enter handling — to be implemented now (no questions, proceed per your “build it”).

## Architecture Decisions

See `context/decision.md` — newest **ADR-017** (blackout + drag fix + blue hover + Enter, checklist), **ADR-016** (hardening), **ADR-015** (independent build), **ADR-014** (9-level slice). Next: **ADR-018** (persist draggable position).

## Pre-Exit Checks (R10 + blackout)

- [x] R10 spec created from Next.js + Flutter package investigation (no code before spec)
- [x] Circle 40dp → pill morph, hover smallest-area, popup only input, history in-memory — implemented and tests green
- [x] `flutter analyze` No issues (root + example), `flutter test` 49 passed, `example` web+windows builds
- [ ] Blackout (black/white) + blue hover + drag handle fix + Enter handling — **IN PROGRESS** (this phase)
- [ ] Checklist `Feature_docs/CHECKLIST.md` + `progress-tracker`/`decision`/`flow` synced — **IN PROGRESS**

## Traceability

- Next.js Agentation → `agentation.com` circle/pill, hover, text/area/multi, pause, layout, marker types, `schema` AFS 1.1, `features` toolbar — mapped to `Feature_docs/R10-circle-hover-history/spec.md: Investigation Summary`.
- Flutter inspectors → `flutter_widget_inspector` smallest-area, `zero_inspector_kit` auto-dock peek, `ispect_layout` compare — mapped to `selection_engine.dart: hovered` + `circle_toggle.dart`.
- User feedback (black, drag, Enter, blue hover, checklist) → this phase + `ADR-017`.
