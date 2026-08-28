# UI Context — Design Language (Flutter Agentation)

## Theme

**Material 3 (Material You)** for all tool UI — overlay chrome, selection indicator, info panel, feedback field, copy CTA. The tool itself is a **precise developer instrument, not an AI app** (`design-statement.md:03-15`, `context.md:94-107`). Communicate: inspection, precision, hierarchy, control, low cognitive load. Avoid excessive decoration.

Default: `ColorScheme.fromSeed` (light + dark); Cupertino only when the host app explicitly requests it. The overlay must not fight the host app's theme — it is chrome that sits *over* it.

## Colors (Tool Overlay)

All overlay colors are tokens in `lib/src/overlay/tokens.dart` / `lib/src/core/config/agentation_theme.dart` — never hardcoded in widgets. Consume via `Theme.of(context).colorScheme` + `ThemeExtension`.

| Role | Token (Dart) | Use |
|------|--------------|-----|
| Selection stroke | `colorScheme.primary` |Bounds indicator around selected widget (1–2px stroke, not fill) |
| Selection fill (hover) | `colorScheme.primaryContainer` @ low alpha | Subtle hover target before tap |
| Panel surface | `colorScheme.surfaceContainerHigh` | Info bottom-sheet / side panel surface |
| Panel scrim | `Colors.black` @ 20–32% if modal; none if side panel | Non-destructive chrome — avoid blocking app |
| On-panel text | `colorScheme.onSurface` | Labels + values in panel |
| Source file link color | `colorScheme.primary` | File:line:column tappable if host supports |
| Error / unavailable | `colorScheme.error` | "Source unavailable in this build" |
| Copy CTA | `FililedButton` on `colorScheme.primary` | Prominent Copy action (`design-statement.md:56-58`) |
| Border / outline | `colorScheme.outlineVariant` | Card and panel dividers |

App-specific extension for tool state:

```dart
@immutable
class AgentationColors extends ThemeExtension<AgentationColors> {
  const AgentationColors({required this.selectionStroke, required this.hoverFill});
  final Color selectionStroke;
  final Color hoverFill;
}
```

## Typography

| Role | Font (Google Fonts via `google_fonts`) | Dart token | Weight |
|------|----------------------------------------|------------|--------|
| Panel headings | **Inter** 600 | `textTheme.titleSmall` | 600 |
| Labels (Widget/Source/Geometry/Hierarchy) | **Inter** 500 | `textTheme.labelMedium` | 500 |
| Values / code (file:line, hierarchy path) | **JetBrains Mono** 400 | mono override of `textTheme.bodySmall` | 400 |
| Feedback field | **Inter** 400 | `textTheme.bodyMedium` | 400 |
| Markdown preview | **JetBrains Mono** 400 | `textTheme.bodySmall` | 400 |

- Panel labels are short and scannable — **do not bury widget type under decoration**.
- Hierarchy is rendered as an indented tree (`Scaffold └── Column └── Card └── ElevatedButton`) — `spec.md:156-159` — not a raw dump.
- Values that may be missing (source) render as styled unavailable text, not blank space (`spec.md:FR-005`).

## Shape & Elevation (M3)

| Context | Value |
|---------|-------|
| Selection indicator | 6–8 radius, 1.5px stroke — precise, not heavy |
| Info panel (bottom sheet) | 16–20 top radius, `surfaceContainerHigh`, elevation 2 |
| Feedback field | 12 radius |
| Copy button | 12 radius (`FilledButton`), full-width on sheet |
| Cards in panel | 12 radius, `Card` with `surfaceContainerLow` |

`BorderRadius.circular` via `ShapeBorder` tokens — no ad-hoc radius in overlay widgets.

## Component Library (Flutter — tool only)

- **Overlay**: `Stack` + `OverlayEntry`/`OverlayPortal` + `Positioned` for selection indicator; `CompositedTransformTarget/Follower` only if needed for anchoring.
- **Panel primitives** in `lib/src/overlay/widgets/`: `AgentationPanel`, `SelectionHighlight`, `InfoRow`, `FeedbackField`, `CopyButton`, `UnavailableLabel`.
- **M3 catalog** directly: `FilledButton`, `TextField`/`TextFormField`, `Card`, `Divider`, `BottomSheet`/`DraggableScrollableSheet`, `SnackBar` for "Copied" toast.
- **Icons**: `Icons.*` (Material) primary — `Icons.bug_report` / `Icons.center_focus_weak` for activation handle, `Icons.content_copy` for copy. No heavy icon packs.
- **Never port web libraries** (Astryx/Animata/MagicUI) — they are DOM/Tailwind; translate inspiration into M3 only (`decision.md:ADR-006`).

## Layout Patterns (V1 — Inspect Mode)

### Activation (`design-statement.md:32-36`)
Compact handle — FAB-small, chip, or keyboard shortcut (`Ctrl/Cmd + .` style) — always reachable but minimal; when inspection is off, **zero impact on host layout/hit-testing** (`architecture.md:72-75`).

### Selection indicator (`design-statement.md:38-41`)
- Clear 1.5px bounding box aligned to `Rect` from `BoundsExtractor`; label badge with widget type.
- Must never obscure the selected widget's own content — stroke-only + small corner handles; avoid opaque fills.

### Info panel (`design-statement.md:43-51`)
Inside the panel, stacked with `Divider`s; copy-scrollable; never full-screen:

```
┌─ Agentation Panel ─────────────────────────────────┐
│ Widget: ElevatedButton (runtime: ElevatedButton)    │
│ Source: lib/screens/home.dart:143:12                │
│  or: Source unavailable in this build (styled)     │
│ Bounds: x=32 y=540 w=320 h=52                      │
│ Hierarchy:                                          │
│  Scaffold                                          │
│   └── Column                                        │
│      └── Card                                       │
│         └── ElevatedButton ◄ selected               │
│ Runtime: text="Get Started" key=...                │
│ ┌ Feedback ──────────────────────────────────────┐ │
│ │ [ Make this more rounded + taller…          ]  │ │
│ └──────────────────────────────────────────────┘   │
│ [ Copy Markdown ]            [ visual evidence ✓ ] │
└─────────────────────────────────────────────────────┘
```

- Hierarchy depth is **bounded** (`spec.md:FR-007`) — cap at nearest ~8 ancestors to avoid huge outputs; truncate with ellipsis and note.
- Feedback field is a single multiline `TextField` (`spec.md:FR-008`); no rich drawing in V1 (`design-statement.md:116-120` forbids V2 UI here).
- Copy is the **primary, prominent** action; toast "Copied" on success.

### Screenshot / Visual evidence
Optional thumbnail in panel; if capture unavailable, row is omitted — never a blocking error (`spec.md:FR-009`). Full image is referenced in Markdown, not large-inline in panel.

## Motion

- **Implicit** first: `AnimatedOpacity` for enable/disable, `AnimatedPositioned` for bounds highlight, `AnimatedSwitcher` for panel content swaps.
- Durations: micro 150, standard 250, entrance 300; `Curves.easeOutCubic`; no layout-thrashing.
- Respect `MediaQuery.disableAnimations` / `accessibleNavigation` — skip heavy motion when true.
- **V2 motion** (resize/move/reshape) is out of scope for this file — tracked in `architecture.md:67-82`.

## Design Principles (`design-statement.md:02-15`, `context.md:94-107`)

- Deterministic, lightweight, inspectable, agent-agnostic, local-first, privacy-conscious, compatible with normal Flutter dev — useful without AI subscription. Developer stays in control.
- **Important**: never infer semantic intent from geometry alone (`design-statement.md:99-113`): preserve both `observed: x 100→140` and `intent: "Align with right edge."` as separate fields — do not pretend one implies the other.

## References

- Design statement: `design-statement.md` (full V1 interface + V2 direction)
- Context philosophy: `context.md:94-107`
- Suggested Markdown layout: `spec.md:134-175`, `architecture.md:166-195`
- M3 spec: https://m3.material.io/ — Flutter M3: https://docs.flutter.dev/ui/design/material
- `ThemeExtension`: https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- `WidgetInspector` / `Element`: https://api.flutter.dev/flutter/widgets/WidgetInspector-class.html
