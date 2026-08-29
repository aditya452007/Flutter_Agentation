# Feature Specification: R12 — Full Rewrite (Premium, Correct Selection, No Distortion)

**Branch**: `R12-rewrite` | **Date**: 2026-08-28 | **Status**: Approved — proceed to rewrite | **Input**: Your “delete and recreate from scratch” + annotation `Stack 1231×161` bug + `agentation.com` circle→pill + `flutter_widget_inspector` smallest-area

## Why Rewrite (Evidence)

Current `lib/src/overlay/agentation_overlay.dart:109` `Stack` with `MouseRegion.onHover → walk(root)` O(N) per pixel + full `Stack` `setState` on every hover → 60fps jank; `pill_toolbar.dart:36` Row 390dp > 320dp overflow + `IconButton` overlay hosted on outer `Material` → white wash over whole pill when hovering Pause; `selection_engine.dart:91` `deepestByBounds` (depth) picks `Text` leaf then lifts but `hoverAt` still picks `Stack`/`Scaffold` huge 1231×161 (your paste) → `Visual Evidence` always false, `Runtime Details` empty. Colors pure `Colors.black` #000 harsh vs premium charcoal #0A0A0A + blur.

## ASCII — Current vs Desired

**Current (bottom-right monolithic, flat, harsh, overflow):**
```
Viewport 390x844
┌─────────────────────────────────────────┐
│ Card 200x200                           │
│  ┌──────────────┐                      │
│  │ Button ◄─────┼─ hover blue wash covers pill
│  └──────────────┘                      │
│                    ┌─────────────────────────────────┐ RIGHT+24
│                    │ ◉ Copy(2) Clear │ ⏸ 👁 ⧉ ✕ │ 380dp → overflow 70px on 320dp
│                    └─────────────────────────────────┘ 0xCC0A0A0A flat, no blur
└─────────────────────────────────────────┘  Positioned(right:24) loose constraints
```

**Desired (centered glass, grouped, charcoal + blur, 8px grid, stagger):**
```
Viewport 390x844
┌─────────────────────────────────────────┐
│ Card 200x200  ← hover blue 1.5px        │
│  ┌──────────────┐                      │
│  │ Button ◄─────┘                      │
│                                        │
│      ┌────────── bottomCenter ──────────┐  Align(bottomCenter) + SafeArea 16
│      │ Backdrop blur 16 0xCC0A0A0A 72% │  ConstrainedBox max 560
│      │ ┌─────┐ ┌──────────┐ ┌─┴─┐ ┌──────────┐ │  gap 8 inside / 16 between groups
│      │ │ ⋮◉ │ │ Copy(2)  │ │ ⏸ │ │ 👁 ⧉ │ │  stagger 40ms*i
│      │ └─────┘ └──────────┘ └─┬─┘ └──────────┘ │  44×44 targets, focus ring 2px
│      └──────────┴──────────┴───┴─┴──────────┘ │  shadow-lg 0 8px 32px
└─────────────────────────────────────────┘
      shadow 1px 2px rgba(0,0,0,0.05) + border 0.08
```

## User Scenarios

### Story 1 — Circle 48dp → Pill centered glass (P1)
As dev I see **48×48 circle** charcoal `0xCC0A0A0A` + cream `F5F0EB` logo + badge, tap → **AnimatedContainer 48→320 220ms easeOutCubic** to **centered pill** (`Align bottomCenter`, `ConstrainedBox max 560`, `ClipRRect 28` + `BackdropFilter blur 16` + `border 0x14FFFFFF`), groups `Logo/drag | Copy/Clear | Pause/Visibility/History | Close` with `gap 8/16` (8px grid), `Copy` primary `FilledButton` 44h, others ghost 44h.

**Test**: `find.byType(CircleToggle)` 48dp → tap → `find.byType(PillToolbar)` centered, `expect(tester.getSize(find.byType(PillToolbar)).width < 560)`.

### Story 2 — Hover correct smallest-area, no wash (P1)
As I move mouse over `Card 200×200` containing `Button 120×60` containing `Text 80×20`, hover shows **Button** (smallest non-Text among 3), not `Stack` 1231×161. Blue `#3B82F6` 1.5px + badge, throttled 16ms, isolated via `ValueListenableBuilder(hovered)` (not full Stack).

**Test**: hover at `Button` center → `hovered.facts.widgetType` contains `Button` or `InkWell`, `hovered.bounds.width < 200`, not `Scaffold` full-screen.

### Story 3 — Click → black popup only, Enter adds (P1)
Click shows **only** `FeedbackPopup` 300×120 `Colors.black` + white hint, **not** hierarchy dump. `Enter` (`onSubmitted`) + `Add` both call `history.add` + reindex, `Esc` cancels. Popup flips above if near bottom.

**Test**: select → `find.text('Say what')` one, `find.text('Hierarchy')` none, `tester.testTextInput.receiveAction(done)` adds entry.

## Requirements

- **FR-001**: Delete `activation_toggle.dart` (legacy), `selection_highlight.dart` duplicate branch, keep `CircleToggle` 48dp + `PillToolbar` glass. New `lib/src/overlay/agentation_shell.dart` using `OverlayPortal` + `CompositedTransformTarget/Follower` for popup positioning (premium, no manual `_popupLeft` math).
- **FR-002**: `SelectionEngine` rewrite: `hitTestInView` with `viewId`, collect candidates via `BoxHitTestResult` path (smallest hittable), map `RenderObject` → `Element` via `debugCreator` ancestor walk, filter chrome (`AgentationOverlay|PillToolbar|CircleToggle|FeedbackPopup`), exclude area >80% screen unless no alternative, sort by area, lift `Text`→`Button`.
- **FR-003**: `SourceResolver` with `Element._location` + `widget._location` + `WidgetInspectorService.getParentChain` fallback, normalize `file://` → `lib/`, test with `const Text` leaf expects `lib/` path.
- **FR-004**: `tokens_premium.dart`: `charcoal #0A0A0A`, `charcoal80 0xCC`, `cream #F5F0EB`, `indigo #6366F1`, `blur 16`, `shadowSm/Md`, `micro 150`, `easeStandard cubic(0.4,0,0.2,1)`, `44×44` min.
- **FR-005**: All 6 platforms, `dart analyze` No issues, `flutter test` 50+.

## Key Entities

- `AgentationShell` (new) — `OverlayPortal` + `CompositedTransform` + `TickerMode` for pause
- `CircleToggle` 48dp, `PillToolbar` centered glass + stagger
- `SelectionEngine` smallest-area + hitTestInView
- `FeedbackPopup` black + Enter
- `AnnotationHistory` + `MarkdownExporter.exportAll`

## Success Criteria

- **SC-001**: Annotation `Stack 1231×161` no longer occurs — selecting `Button` center yields `ElevatedButton`/`InkWell` with `width<200` and `source lib/...` when debug.
- **SC-002**: Hover over Pause shows 36×36 blue border on button, not pill wash or full-screen.
- **SC-003**: Pill centered, max 560, no overflow on 320dp, blur visible, staggered entrance 40ms*i.
