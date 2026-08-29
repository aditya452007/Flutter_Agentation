# Progress Tracker — Flutter Agentation

## Current Phase

**Phase 5 — Distortion Fix & Premium Polish (IN PROGRESS) — hover throttle, pill centered glass, blackout subtle**
**Previous: R10 circle→pill + hover + popup + history (COMPLETE, 49 tests green, Windows build 36s)**

V1 scope: `spec.md:FR-001–FR-014` + R10 blackout/hover/history. Latest Flutter 3.44.9 / Dart 3.12.2. No V2 visual manipulation or V3 MCP yet (seams only).

## Current Goal — Fix Distortion + Premium Feel (your latest feedback)

1. **Distortion when hovering Pause (i)** — `PillToolbar` `IconButton` hover `overlayColor` paints on outer `Material` (pill) not button, plus `MouseRegion` O(N) walk at 60fps + `Stack` rebuild + `Row` 390dp > 320dp overflow → appears as pill covering screen. Fix: throttle 16ms ✅, isolate hover via `ValueListenableBuilder`, give each `IconButton` its own `Material`/`shape:CircleBorder`, make pill `SingleChildScrollView` + `ConstrainedBox` max 560, exclude overlay chrome from `SelectionEngine` walk, add 80% screen area cap.

2. **Circle → Pill layout** — was `Positioned(right:24,bottom:24)` mono pill at bottom-right, flat Row, pure black #000 harsh, no blur, no stagger. Original Next.js is **centered bottom** `Align(bottomCenter)` + `ConstrainedBox(maxWidth: min(560, screenW-32))` + `SafeArea 16` + `ClipRRect 16` + `BackdropFilter blur 16` + `charcoal 0x0A0A0A 72%` + `border 0x14FFFFFF` + shadow-lg, grouped `Row(gap:8)` with `VerticalDivider`, `Copy` primary `FilledButton` others ghost 44x44, `AnimatedContainer` 40→240 220ms `easeOutCubic` morph + stagger `40ms*i`.

3. **Blackout subtle** — pure `Colors.black` on all chrome is 21:1 harsh. Premium `color-theory.md:16` uses `charcoal #0A0A0A` + `cream #F5F0EB` + `indigo #6366F1` accent, `shadow-sm 0 1px 2px rgba(0,0,0,0.05)`, `blur 20`. Change: `circle_toggle.dart:23` `Colors.black` → `Color(0xFF0A0A0A)` + `0xCC` + blur, `pill_toolbar.dart:31` same, `feedback_popup.dart:39` same, `history sheet` `Color(0xFF141414)` + `barrier 0x52000000`.

4. **Visual Evidence empty** — `lib/src/exporter/markdown_exporter.dart:6` `screenshotAvailable` always false by design V1 (see `Feature_docs/CHECKLIST.md:38` Screenshot V2). Will implement `ScreenshotService` via `RepaintBoundary.toImage` in R11, for now document as “No screenshot captured.” + hide empty `Runtime Details` `No additional properties` vs show “No additional properties”.

5. **Checklist** — `Feature_docs/CHECKLIST.md` + `Feature_docs/CHECKLIST_V2.md` now enumerates 14 implemented vs 16 missing (text/area/multi, pause real, layout palette 65+, computed styles, shortcuts, MCP). See audit parallel agents.

## Completed (since `de99b0b` blackout)

- **Blackout** `circle_toggle.dart:23` `Colors.black` + white icon, `pill_toolbar.dart:31` `Colors.black` + white, `feedback_popup.dart:39` black + white, `agentation_overlay.dart:45` history sheet black.
- **Hover blue** `agentation_overlay.dart:117` `Color(0xFF3B82F6)` 1.5px + badge, `selection_engine.dart:9` smallest-area + `Text` lift.
- **Draggable** `agentation_overlay.dart:183` circle draggable `onPanUpdate` → `_dragOffset` + `_autoDock()` 12px peek, pill fixed (not draggable) to avoid button vs pan conflict.
- **Tests** `test/overlay/activation_toggle_test.dart:34` 4 tests for circle→pill + hover+popup, 49 tests green, `dart analyze` No issues, `example` web+windows builds.
- **Docs** `Feature_docs/R10-circle-hover-history/spec.md:1` + `Feature_docs/CHECKLIST.md` + `Feature_docs/CHECKLIST_R10_POLISH.md` + investigation via 3 parallel `Task` agents (overlay distortion, premium gaps, visual evidence).

## Next Up (small & working — distortion must-fix first)

1. **Isolate hover rebuild** — wrap hover `Positioned` in `ValueListenableBuilder(hovered)` not full `Stack` `setState` on every `onHover` (currently `_onChange` rebuilds pill even though idle).
2. **Exclude overlay chrome from walk** — `selection_engine.dart:92` `if (element.widget is AgentationOverlay || PillToolbar || CircleToggle) return;` + area cap 80% screen to ignore `Stack`/`Scaffold` huge.
3. **Center pill** — `agentation_overlay.dart:213` `Positioned(right:24)` → `Align(bottomCenter) + ConstrainedBox(maxWidth:560) + SafeArea 16` + `ClipRRect 16` + `BackdropFilter blur 16` (premium BOLD glass).
4. **Fix white-on-white Pause** — `pill_toolbar.dart:74` give each `IconButton` `Material(type:transparency, shape:CircleBorder)` so `Ink` not hosted by outer pill `Material`.
5. **Premium tokens** — `lib/src/overlay/tokens.dart:17` expand to charcoal/cream/indigo/blur/shadowSm/Md/ micro 150ms `easeStandard Cubic(0.4,0,0.2,1)` + stagger 40ms, then apply to circle/pill/popup/history.
6. **Verify** — `dart analyze`, `flutter test` (49+), `example` web/windows, manual: hover Pause should show tiny 36×36 blue border around button, not pill-sized wash.

## Open Questions (for you — ask up front per your instruction)

- Q9: Layout Mode visual tool — should we start `V2-01` Palette 20 types (vs 65+) in `R11` or defer until distortion + premium polish is fully approved?
- Q10: Text selection vs element — when hovering over `Text('Get Started')` inside `ElevatedButton`, should hover show `Text` (smallest-area) or `ElevatedButton` (lifted)? Current lifts to `Button` — is that desired or should hover stay on `Text`?
- Q11: Persist drag offset/history 7d via `SharedPreferences` now or keep in-memory per R10 spec?

## Architecture Decisions

See `context/decision.md` — newest **ADR-017** blackout/drag/blue, next **ADR-018** distortion + premium polish (throttle, centered glass, smallest-area fix, charcoal). Next: **ADR-019** visual tool palette.

## Pre-Exit Checks (this phase)

- [x] R10 blackout + hover + history implemented, 49 tests green
- [ ] Distortion 1-4 fixed (throttle isolation, pill scroll/constraints, badge Clip.none, Pause white-on-white)
- [ ] Premium S1-S12 fixed (charcoal + blur + stagger + 44×44 + focus ring)
- [ ] Visual Evidence documented vs implemented (ScreenshotService)
- [ ] `Feature_docs/CHECKLIST.md` + `CHECKLIST_V2.md` + `CHECKLIST_R10_POLISH.md` synced
- [ ] `progress-tracker`/`decision`/`flow` synced — **IN PROGRESS** (this file)

## Traceability

- Next.js Agentation → `agentation.com/features` circle→pill, hover, text/area/multi, pause, layout palette 65+, `schema` AFS 1.1 → mapped to `Feature_docs/R10` + `Feature_docs/CHECKLIST_V2.md`.
- Flutter inspectors → `flutter_widget_inspector` smallest-area + `zero_inspector_kit` auto-dock peek → mapped to `selection_engine.dart` + `circle_toggle.dart`.
- Your feedback (black, drag, Enter, blue hover, checklist, premium, visual evidence, Pause distortion) → this phase + `ADR-017` + `ADR-018` next.
