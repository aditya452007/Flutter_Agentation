# Agentation Feature Checklist — Flutter vs Next.js Original

**Date**: 2026-08-28 | **Spec**: `Feature_docs/R10-circle-hover-history/spec.md:1` + Next.js `agentation.com` investigation

## Implemented (V1 + R10)

| # | Feature | Next.js Original | Flutter Status | File |
|---|---------|------------------|----------------|------|
| 1 | **Circle entry 40dp logo** | Bottom-right circle logo | ✅ `lib/src/overlay/circle_toggle.dart:1` black/white + badge |
| 2 | **Circle → Pill morph** | Click circle → expand to pill 220ms | ✅ `lib/src/overlay/agentation_overlay.dart:183` `isExpanded` 40→240 width |
| 3 | **Pill toolbar full** | Copy/Clear/Pause/Visibility/History/Close | ✅ `lib/src/overlay/pill_toolbar.dart:1` black/white, `AgentationController` `isPaused/isVisible` |
| 4 | **Draggable + auto-dock 12px peek** | Toolbar draggable, auto-dock (zero_inspector_kit pattern) | ✅ Circle draggable (`_dragOffset` + `_autoDock()`), pill fixed to avoid button conflict |
| 5 | **Hover border + badge** | Hover highlights with name, smart identification | ✅ `SelectionEngine.hoverAt` smallest-area (`lib/src/selection/selection_engine.dart:9`) + `MouseRegion` + blue `Color(0xFF3B82F6)` border `lib/src/overlay/agentation_overlay.dart:117` |
| 6 | **Smallest-area selection** | `flutter_widget_inspector` smallest-area vs deepest depth | ✅ `selection_engine.dart:9` `width*height` + `Text` lift to `Button/Card/Tile`, `hierarchy_extractor.dart:9` filter `_` private |
| 7 | **Click → only input popup** | Click shows text box only, hierarchy only in Markdown | ✅ `lib/src/annotation/feedback_popup.dart:1` 300×120 black card `Say what to change…` + `Add`/`Cancel`, `Enter` via `onSubmitted` + `textInputAction:done` |
| 8 | **History multi + delete** | Numbered markers 1,2… + list + delete/clear | ✅ `lib/src/annotation/annotation_history.dart:1` `add/remove/clear` reindex, `PillToolbar` badge, `agentation_overlay.dart:45` `_showHistorySheet` black sheet with delete |
| 9 | **Copy Markdown** | Structured `Target/Source/Geometry/Hierarchy/Runtime/Feedback` | ✅ `lib/src/exporter/markdown_exporter.dart:1` `export` + `exportAll` (one `## Annotation n` per entry), deterministic, escaping |
| 10 | **Blackout theme** | N/A (Next.js is light/dark toggle) — your feedback | ✅ Circle/pill/popup/history all `Colors.black` + `Colors.white` icons/text for contrast |
| 11 | **Enter handling** | `Add` via button or `Enter` | ✅ `FeedbackPopup` `onSubmitted` → `addAnnotation` + `textInputAction:done` + black `FilledButton` |
| 12 | **Hover blue/indigo** | Reference docs blue highlight | ✅ `Color(0xFF3B82F6)` (indigo-blue) for hover border + badge |
| 13 | **Smart identification** | CSS selectors + React tree | ✅ `WidgetResolver` + `HierarchyExtractor` filter + `SourceResolver._location` → `lib/...` relative, `Markdown` includes `hierarchy` root→leaf |
| 14 | **Zero-cost disable** | `enabled:false` returns `child` | ✅ `AgentationController.isEnabled` + `MouseRegion` only when enabled, `Positioned` only when has bounds |

## Missing — Not Yet Implemented (Proposed for R11/R12 or V2/V3)

| # | Feature | Next.js / Flutter Package | Priority | Proposal |
|---|---------|---------------------------|----------|----------|
| 15 | **Text selection** (select exact text, not element) | Next.js: select text to annotate typos, `ispect` text section | P1 | `TextSelection` via `SelectableText` + `TextExtractor` deep span traversal |
| 16 | **Multi-select** (drag to select multiple elements) | Next.js: Multi-Select (always green markers) | P2 | `Drag` to collect `List<SelectionResult>` → history add batch |
| 17 | **Area selection** (drag any region, even empty space) | Next.js: Area, `ispect_layout` compare mode | P2 | `Listener` drag rect → `RectInfo` without widget, note “empty area” |
| 18 | **Animation pause** (freeze all animations to capture state) | Next.js: Pause • Freeze CSS/JS/videos, toolbar Pause | P2 | `TickerMode(enabled: !isPaused)` + `AnimationController` pause — currently `isPaused` only blocks hover/select, not real freeze |
| 19 | **Layout mode** (`L` to drag components, place 65+ types, wireframe) | Next.js: Layout Mode palette, `L` shortcut | V2 | `VisualChanges` stub → `OverrideState` (move/resize) per `architecture.md:67` |
| 20 | **Computed styles** (colors, fonts, spacing) | Next.js: Computed styles collapsible, `flutter_widget_inspector` decoration section | P2 | `ComputedStyleExtractor` via `RenderBox` + `TextStyle` → include in `WidgetFacts.properties` |
| 21 | **React detection modes** (Compact/Standard/Detailed/Forensic) | Next.js: `React Components` Hide/Filter/Smart/All | P3 | `HierarchyExtractor` modes: filter level 0/1/2/3 (currently filtered Standard) |
| 22 | **Marker types** (1 vs 1 green for multi/area) | Next.js: marker color per type | P2 | `SelectionHighlight` color param: single `indigo`, multi/area `Colors.green` |
| 23 | **Dark/light persist** | Next.js: toggle persists to `localStorage` | P3 | `SharedPreferences` for `ThemeMode` + marker color |
| 24 | **Keyboard shortcuts** | Next.js: `Cmd+Shift+F`, `Esc`, `L`, `P`, `H`, `C`, `X` | P2 | `Shortcuts` + `Actions` for `Esc` (close popup), `C` (copy), `X` (clear) |
| 25 | **Screenshots / visual evidence** | Next.js: No screenshots (text-only), `ispect_layout` color picker | V2 | `RepaintBoundary` + `toImage` → `Visual Evidence` base64 or file ref |
| 26 | **MCP sync** (real-time two-way, `agentation_get_all_pending` etc.) | Next.js: MCP server `http://127.0.0.1:4747`, `ispect` export | V3 | `MCPServer` over `ContextModel` per `architecture.md:83` |
| 27 | **Per-page 7d persistence** | Next.js: `localStorage` 7 days | P3 | `SharedPreferences` + `DateTime` expiry for `AnnotationHistory` |
| 28 | **Text/area via drag threshold** | Next.js: drag vs click threshold 6px | P1 | Add `kDragThreshold 6.0` to distinguish tap vs drag in `GestureDetector` (currently tap vs pan may still conflict) |
| 29 | **Source link navigation** | Next.js: `navigateToUrl` for component source links | P3 | `SourceLocation` `onTap` → `launchUrl` or `navigateToUrl` callback |
| 30 | **Zero-cost disable in release** | `flutter_widget_inspector` `enabled: kDebugMode` | P1 | Wrap `AgentationOverlay` with `kDebugMode` guard in `example` + `const` check |

## Immediate Next (R10 Polish Remaining)

- [ ] Fix drag handle: pill buttons still use whole-pill `GestureDetector` for drag — should be handle-only (logo drag) — currently pill is not draggable (fixed to avoid button conflict) but circle is draggable; need handle for pill too.
- [ ] Add `SharedPreferences` persistence for `_dragOffset` (currently in-memory).
- [ ] Add `Shortcuts` for `Enter` in `FeedbackPopup` already, plus `Esc` to cancel.
- [ ] Verify hover `blue` is visible on both light and dark app themes (currently `0xFF3B82F6` 0.6 border + 0.06 fill).
- [ ] Add widget test for `AnnotationHistory` add/delete/reindex + `exportAll`.

All implemented items are tested via `test/overlay/activation_toggle_test.dart` (4), `test/selection/selection_engine_test.dart` (6), `test/resolver/widget_resolver_test.dart` (10), `test/exporter/markdown_exporter_test.dart` (7) — total 49, plus `flutter analyze` No issues.
