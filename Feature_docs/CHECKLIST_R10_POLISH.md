# Checklist — R10 Polish (Blackout, Drag, Blue Hover, Enter) + Premium Fixes

## Implemented (after hardening)

| # | Feature | File | Status |
|---|---------|------|--------|
| 1 | Circle 40dp black/white + badge | `lib/src/overlay/circle_toggle.dart:23` | ✅ |
| 2 | Pill black/white full toolbar | `lib/src/overlay/pill_toolbar.dart:31` | ✅ |
| 3 | Hover blue #3B82F6 | `lib/src/overlay/agentation_overlay.dart:117` | ✅ |
| 4 | Feedback popup black | `lib/src/annotation/feedback_popup.dart:39` | ✅ |
| 5 | History sheet black | `lib/src/overlay/agentation_overlay.dart:45` | ✅ |
| 6 | Draggable circle | `lib/src/overlay/agentation_overlay.dart:183` | ✅ (pill fixed) |

## Still To Fix (from parallel agents)

| # | Issue | Evidence | Fix |
|---|-------|----------|-----|
| **Distortion 1** | Hover rebuild loop 60fps O(N) walk | `selection_engine.dart:91` walk on every pixel, `agentation_overlay.dart:36` setState each hover | Add 16ms throttle + debounce, cache candidates, only rebuild hover border not whole pill |
| **Distortion 2** | Pill Row overflow 390dp > 320dp | `pill_toolbar.dart:36` Row min 390dp, `IconButton` 48dp, `Badge` shift | Wrap Row in `SingleChildScrollView` horizontal or use `ConstrainedBox` + `Wrap`, reduce IconButton constraints to 40dp |
| **Distortion 3** | Hover badge top:-16 clip outside viewport | `agentation_overlay.dart:124` top:-16 with Clip.none | Use `AnimatedPositioned` with offset that flips inside viewport, add SafeArea, use `Clip.none` only for border |
| **Distortion 4** | White-on-white Pause bug | `pill_toolbar.dart:74` background white but icon white → invisible | Fix `foregroundColor` to black when paused |
| **Premium S1** | Pure black #000 harsh | All chrome | Use charcoal `#0A0A0A` + cream `#F5F0EB`, blur 20 |
| **Premium S2** | No morph 220ms | `agentation_overlay.dart:189` ternary swap | Add `AnimatedSwitcher` + `AnimatedContainer` 40→240 |
| **Visual Evidence empty** | `screenshotAvailable` always false | `markdown_exporter.dart:6`, `agentation_controller.dart:47` | Implement `ScreenshotService` via RepaintBoundary or document as by-design V1, show placeholder |
| **Sections empty** | `semantics`/`properties` never set | `widget_resolver.dart:30` | Add `SemanticsResolver` or hide empty sections |

## Next Steps

1. Throttle hover (16ms) + make hover border only rebuild (ValueListenableBuilder for hover)
2. Pill make scrollable + reduce constraints
3. Fix hover badge clipping
4. Premium tokens (charcoal, blur, stagger) — low priority vs distortion
