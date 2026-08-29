# Feature Specification: V2-S1 — Palette + Drag-to-Place + Wireframe Shell

**Branch**: `v2-s1-layout-palette` | **Date**: 2026-08-28 | **Status**: Approved — go on | **Input**: Next.js `agentation.com/features` Layout Mode (palette 65+, drag place/rearrange, wireframe opacity + purpose, `kind:placement/rearrange` MCP hints)

## User Scenarios

### Story 1 — Enter Layout Mode via L or pill (P1)

As dev I press `L` or tap `Layout` in pill → palette 320×400 appears left 16 top 80 with 20 types grid, app behind dims via wireframe overlay. Press `L` again → palette hides, wireframe off.

**Test**: `tester.sendKeyEvent(LogicalKeyboardKey.keyL)` → `find.byType(LayoutPalette)` one; again → zero.

### Story 2 — Drag a type onto canvas as spatial hint (P1)

As dev I long-press `Card` tile in palette → drag ghost (dashed border) → drop at center → a `Placement` entry appears in history as `kind:placement` with `componentType: Card` + relative rect `x% y% w% h%` + `purpose` field, not mutating real tree. A translucent ghost stays as overlay.

**Test**: Drag `Card` tile to `Offset(200,200)` → `controller.layout.placements.length == 1` + `placements[0].componentType == 'Card'`.

### Story 3 — Wireframe opacity + purpose syncs to export (P1)

As dev I drag `Opacity` slider to 0.6 → app dims 40% + grid shows; I type `purpose: landing hero` → `Copy` exports `## Visual Changes` with `Wireframe: opacity 0.6, purpose: landing hero` + `Placement: Card at 50%,40% 30%×20%`.

**Test**: Set `wireframeOpacity=0.6` + `purpose='hero'` → `exportAll` contains `Wireframe:` and `Placement:`.

## Requirements

- **FR-001**: Palette 20 types (Container, Column, Row, Stack, Card, ListTile, ElevatedButton, OutlinedButton, Text, Icon, Image, Chip, Divider, ListView, GridView, TabBar, AppBar, BottomNavigationBar, FloatingActionButton, SizedBox) — expand to 65 later. Model `lib/src/visual/palette_model.dart` `PaletteItem{String type, IconData icon}`.
- **FR-002**: `VisualChanges` sealed: `VisualPlacement{String componentType, RectInfo relativeRect, String? purpose}` + `VisualRearrange{String elementId, RectInfo from, RectInfo to}` (stub for now) in `lib/src/context/visual_changes.dart:8`.
- **FR-003**: `LayoutController` `lib/src/visual/layout_controller.dart` `ValueNotifier<List<VisualPlacement>> placements` + `wireframeOpacity` `0..1` + `purpose` + `toVisualChanges()` + `clear()`, owned by `AgentationController`.
- **FR-004**: Pill adds `Layout` `Icons.view_quilt` toggle (active `Colors.white` bg) + `Send` `Icons.send` (disabled until MCP, tooltip “Configure webhook to enable”) in `lib/src/overlay/pill_toolbar.dart:31` Group D.
- **FR-005**: Overlay mounts `LayoutPalette` `Positioned(left:16,top:80)` 320×400 `GridView` 3-col `LongPressDraggable<PaletteItem>` when `isLayoutMode`, and `WireframeOverlay` `Opacity(1-opacity)` + `CustomPaint` dashed grid, `DragTarget<PaletteItem>` on app stack creates ghost `Positioned` dashed border at drop `relativePosition`.
- **FR-006**: `Shortcuts` `L` toggles layout, `Esc` cancels palette/wireframe, `P`/`H`/`C`/`X` already in `AgentationOverlay` — add `L`.
- **FR-007**: `MarkdownExporter` appends `## Visual Changes` when any `visual != null` — one block per `Placement`/`Rearrange` + wireframe line.
- **FR-008**: `dart analyze` No issues, `flutter test` new `test/visual/layout_controller_test.dart` 5 cases + `test/overlay/layout_palette_test.dart` drag test.

## Key Entities

- `PaletteItem`, `LayoutController`, `VisualPlacement`, `VisualRearrange`, `WireframeOverlay`, `LayoutPalette`, `PillToolbar` Layout button.

## Success Criteria

- **SC-001**: `L` toggles palette, drag `Card` creates placement, slider + purpose appear in `exportAll`.
- **SC-002**: Real widget tree untouched — ghost is `OverlayEntry` dashed, not `setState` on app widgets.
- **SC-003**: `example` builds `web`+`windows`, `flutter test` 50+ green.

## Assumptions

- Palette 20 not 65 for V2-S1; `Send` disabled until `webhookUrl` (like Next.js `auto-send` off).
- Relative rect is `globalOffset / viewportSize` (*100%) — spatial hint, not pixel-perfect per Next.js.
