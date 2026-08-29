# Visual Tool & Premium Checklist — Agentation Parity (Next.js vs Flutter)

**Date**: 2026-08-29 | **Refs**: `agentation.com/features` (Pause/Visibility/Copy/Clear/Send/Layout/Settings, Text/Elements/Multi/Area/Animation, palette 65+), `flutter_widget_inspector` (smallest-area, red highlight, rulers), `Feature_docs/CHECKLIST.md` + `CHECKLIST_R10_POLISH.md`

## Implemented (V1+R10) — Keep

| # | Feature | File |
|---|---------|------|
| 1 | Circle 40dp → pill morph | `lib/src/overlay/circle_toggle.dart:23`, `agentation_overlay.dart:189` |
| 2 | Pill Copy/Clear/Pause/Visibility/History | `lib/src/overlay/pill_toolbar.dart:31` |
| 3 | Hover blue #3B82F6 + smallest-area + Text lift | `lib/src/selection/selection_engine.dart:9`, `agentation_overlay.dart:117` |
| 4 | Click → black popup only | `lib/src/annotation/feedback_popup.dart:39` |
| 5 | History 1..n + delete + Copy all | `lib/src/annotation/annotation_history.dart:1` |
| 6 | Blackout theme (circle/pill/popup black/white) | `circle_toggle.dart:23`, `pill_toolbar.dart:31`, `feedback_popup.dart:39` |

## Still Missing — Next.js Agentation Visual Tool (Build in R11)

| # | Feature | Next.js Spec | Flutter Gap | Priority |
|---|---------|--------------|-------------|----------|
| **V2-01** | **Layout Mode `L`** — enter layout, toolbar shows `Layout Mode` | `agentation.com/features` Layout Mode palette 65+ | No `isLayoutMode`, no palette, `visual_changes.dart` empty stub | **V2 P1** |
| **V2-02** | **Palette 65+ drag-to-place** — Container/Box/Text/Button etc. | Next.js: drag from palette onto page | No `Draggable` palette, no `DragTarget` | **V2 P1** |
| **V2-03** | **Rearrange** — grab existing and drag to reposition | Next.js: grab section → reposition, `kind:rearrange` | No `onPan` on highlight, no `Rearrange` model | **V2 P1** |
| **V2-04** | **Wireframe + opacity slider + purpose** | Next.js: fade page, opacity slider, purpose field, `kind:placement` | No `WireframeOverlay`, no slider/purpose | **V2 P2** |
| **V2-05** | **Send via webhook/MCP** — `Send` button when `webhookUrl` set | Next.js: Send when webhooks enabled | No `WebhookService`, `PillToolbar` has no Send | **V2 P2** |
| **V2-06** | **Computed styles** collapsible — colors/fonts/spacing | Next.js: Computed styles chevron, `flutter_widget_inspector` decoration section | `WidgetFacts.properties` always null (`widget_resolver.dart:30`) | **P2** |
| **V2-07** | **Text selection** (exact text quote) | Next.js: Text mode, `“simpl”` | `text_extractor.dart:8` shallow only | **P1** |
| **V2-08** | **Multi-select / Area** (drag rect, green markers) | Next.js: Multi green `1`, Area any region | `selection_engine.dart:27` single only | **P2** |

## Still Missing — Polish / Premium (Fix Distortion + Feel Premium)

| # | Issue | Evidence | Fix (premium) |
|---|-------|----------|--------------|
| **P-01** | Hover rebuild 60fps jank (covers screen) | `agentation_overlay.dart:36` `setState` on every `MouseRegion` pixel + `walk(root)` O(N) | Throttle 16ms ✅ + isolate hover via `ValueListenableBuilder`, add `hovered != selected` guard, exclude overlay chrome from walk, area cap 80% screen |
| **P-02** | Pill overflow 390>320 | `pill_toolbar.dart:36` Row 390dp | Wrap `Row` in `SingleChildScrollView` ✅ + reduce `IconButton` to 36 `shrinkWrap` + `ConstrainedBox` max 560 centered bottom (`Align bottomCenter`) |
| **P-03** | Pure black harsh, no blur | `Colors.black` 8× | Use charcoal `0xFF0A0A0A` 72% `0xCC` + `BackdropFilter blur 16` + border `0x14FFFFFF` + `shadow-lg` (premium BOLD glass) |
| **P-04** | No morph, instant swap | `agentation_overlay.dart:189` ternary | `AnimatedSwitcher` + `AnimatedContainer` 40→240 220ms `easeOutCubic` |
| **P-05** | White-on-white Pause bug | `pill_toolbar:74` `background white` but `icon white` | `IconButton.styleFrom` with `foregroundColor` black when paused, `overlayColor` 0x14 white |
| **P-06** | Sections empty (Source/Geometry/Runtime) | `source_resolver` null gracefully, `properties` never set | Document as by-design per `ADR-009`; optional add `SemanticsResolver` or hide empty `Divider` |
| **P-07** | Visual Evidence always “No screenshot” | `markdown_exporter` `screenshotAvailable` always false | Implement `ScreenshotService` via `RepaintBoundary.toImage` or keep as V2 placeholder with docs |

## Immediate Next (Distortion Must-Fix)

- [ ] Exclude `AgentationOverlay`/`PillToolbar`/`CircleToggle` from `selection_engine` walk
- [ ] Add 80% screen area cap to ignore `Stack`/`Scaffold` full-screen
- [ ] Isolate hover border rebuild (`ValueListenableBuilder` for hover only)
- [ ] Center pill: `Align(bottomCenter) + ConstrainedBox(maxWidth: min(560, screenW-32))` + `SafeArea 16` + `ClipRRect 16` + `BackdropFilter blur 16`
