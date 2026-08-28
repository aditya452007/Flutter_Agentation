# Feature Specification: L04 — Overlay & Activation

**Feature Branch**: `L04-overlay-activation`

**Created**: 2026-08-28

**Status**: Draft — depends on L00, L01, L02, L03

**Input**: `architecture.md:3.1` Overlay + `design-statement.md:30-58` V1 Interface + `spec.md:FR-001/FR-002/FR-003` (activation + selection + overlay) + `context/progress-tracker.md` decision doc-only first

## User Scenarios & Testing

### User Story 1 — Activate/deactivate inspection (Priority: P1)

As the developer, I want a compact control to enable inspection that, when off, makes the tool **invisible and non-interfering** with my app's gestures/scroll.

**Why P1**: `spec.md:FR-001` + `architecture.md:72-75` non-destructive chrome.

**Independent Test**: Pump `AgenationOverlay.wrap(child: MyScaffold())` → `tester.tap(activationToggle)` → `controller.isEnabled == true`; tap again → `false`; when `false`, a `ListView` underneath still scrolls normally.

**Acceptance Scenarios**:
1. **Given** inspection disabled, **When** dragging a scrollable, **Then** scroll works (no overlay absorbing gestures)
2. **Given** inspection enabled, **When** tapping a widget, **Then** `SelectionEngine.selectAt` is called and highlight appears

---

### User Story 2 — Selection highlight is precise and non-obscuring (Priority: P1)

As the developer, I see a 1.5px stroke bounding box exactly at `SelectionResult.bounds` plus a small badge with `widgetType`, not a filled overlay that hides the app.

**Why P1**: `spec.md:FR-003` + `design-statement.md:38-41` — "visually obvious without obscuring."

**Independent Test**: Select a 320×52 button → `find.byType(SelectionHighlight)` paint bounds match `RectInfo` with hairline stroke + badge text contains `ElevatedButton`.

**Acceptance Scenarios**:
1. **Given** a selected widget with known bounds, **When** overlay paints, **Then** highlight Rect equals `bounds` ±0.5px and badge is visible
2. **Given** `bounds == null` (non-RenderBox), **When** selected, **Then** overlay shows badge only, no crash, and info panel still appears

---

### User Story 3 — Overlay lifecycle ties to selection stream (Priority: P2)

As the overlay, I react to `SelectionEngine.selected` changes and to activation toggles, and I clean up listeners on dispose.

**Why P2**: Prevents leaks and ensures highlight clears when inspection is turned off.

**Independent Test**: Toggle enabled off → `selected.value` is kept but highlight disappears; dispose overlay → no `selected` listeners remain.

**Acceptance Scenarios**:
1. **Given** inspection enabled + selection present, **When** disabling inspection, **Then** highlight is removed but `SelectionResult` is retained (so re-enabling can restore)
2. **Given** overlay disposed, **When** checking `selectionEngine.hasListeners`, **Then** false

---

### Edge Cases

- Keyboard activation (`Ctrl/Cmd + I`) optional in V1 — if not built, activation is tap-only; either way overlay must not block text field focus when disabled.
- `OverlayPortal` vs `OverlayEntry` — Flutter 3.44 uses `OverlayPortal` preferred; handle both.
- `MediaQuery.disableAnimations` — highlight entrance should respect reduced motion (no animation or `Duration.zero`).
- Hot reload while inspection enabled — highlight must re-resolve bounds, not show stale Rect.

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide `AgenationOverlay` widget that wraps `child: Widget` and inserts an `OverlayPortal`/`OverlayEntry` for chrome. Public API: `AgenationOverlay.wrap(child: MyApp)` and `AgenationOverlay(controller: ctl, child: ...)`.
- **FR-002**: System MUST provide `AgenationController` with `ValueNotifier<bool> isEnabled` and `ValueNotifier<SelectionResult?> selected` (exposed). `toggle()/enable()/disable()` helpers. Controller owns no network/AI.
- **FR-003**: Activation control MUST be a compact M3 widget (small `FloatingActionButton.small` or `ActionChip("Inspect OFF/ON")`) anchored to bottom-right with safe-area, tappable, and accessible (semantics label "Toggle inspection"). Style: neutral `surfaceContainerHigh`, `primary` active state — not a purple gradient.
- **FR-004**: Highlight MUST be a `CustomPainter`/`DecoratedBox` stroke (1.5px, `colorScheme.primary`) aligned to `RectInfo` in overlay coordinates (`globalOffset` translation via `overlayContext.findRenderObject()`); badge is a small `Material` chip with `widgetType`.
- **FR-005**: When `isEnabled == false`, overlay MUST NOT install pointer listeners that absorb gestures — `Listener`/`GestureDetector` behavior set to `translucent` only when enabled, `deferToChild` otherwise (or not mounted).
- **FR-006**: Overlay MUST listen to `SelectionEngine.selected` (from L03) and repaint highlight on change; MUST also listen to `WidgetsBindingObserver.didChangeMetrics` to re-derive bounds on resize/orientation.
- **FR-007**: All overlay widgets MUST use `Theme.of(context).colorScheme` / `ThemeExtension` — no hardcoded colors (`context/code-standards.md`).
- **FR-008**: Overlay MUST respect `MediaQuery.disableAnimations` — highlight enters instantly when true, else `AnimatedPositioned(Duration(milliseconds: 80))` at most.

### Key Entities

- **AgenationController**: `{ ValueNotifier<bool> isEnabled; ValueNotifier<SelectionResult?> selected; SelectionEngine engine; }` — small, focused, per `build-instructions.md:Code Quality`.
- **AgenationOverlay**: `StatelessWidget/StatefulWidget` that mounts portal + activation control + highlight + listener wiring.
- **SelectionHighlight**: `StatelessWidget({required RectInfo? bounds, required String label, bool hasBounds})` — pure presentational.
- **ActivationToggle**: compact button widget.

## Success Criteria

- **SC-001**: `flutter test` widget tests: activation toggle, highlight alignment, disabled passthrough scroll, cleanup on dispose — 6+ cases.
- **SC-002**: Golden test for highlight (stroke + badge) at 1.5px, not filled.
- **SC-003**: `flutter analyze` → No issues; no hardcoded colors detected (manual review + lint).
- **SC-004**: Manual demo (from L04 onward, even before L08 demo app): enable → tap → highlight appears precisely; disable → app gestures unaffected.

## Assumptions

- `AgenationController` is provided via `InheritedNotifier` or `Provider`-less `ValueListenableBuilder` — no external state package needed in V1 (keeps deps minimal).
- Demo scroll test uses a `ListView` inside `AgenationOverlay.wrap`.

---

## Technical Design

### Languages & Versions

| Layer | Language | Version |
|-------|----------|---------|
| Overlay | Dart 3.12.2 / Flutter 3.44.9 | `flutter/widgets.dart`, `material.dart`, `rendering.dart` |
| State | `ValueNotifier` / `ChangeNotifier` | No Bloc/Riverpod in V1 |

### Folder Structure

```text
lib/
├── src/
│   ├── context/               # L01
│   ├── resolver/              # L02
│   ├── selection/             # L03
│   └── overlay/               # NEW
│       ├── agentation_overlay.dart    # AgentationOverlay
│       ├── agentation_controller.dart # AgentationController
│       ├── selection_highlight.dart   # SelectionHighlight + painter
│       ├── activation_toggle.dart     # ActivationToggle
│       └── tokens.dart                # AgentationColors ThemeExtension, spacing
├── agentation.dart            # barrel export
test/
├── overlay/
│   ├── overlay_activation_test.dart
│   ├── highlight_golden_test.dart
│   └── controller_test.dart
```

ASCII — overlay composition (when enabled):

```text
AgenationOverlay.wrap(child: Scaffold(...))
  |
  +-- Stack
       +-- child: Scaffold(...)                    // app — untouchable when disabled
       +-- OverlayPortal
            +-- ActivationToggle  [bottomRight, safeArea]
            |     "Inspect OFF" (neutral) / "Inspect ON" (primary)
            |
            +-- if (selected != null) SelectionHighlight
                  +-- Positioned(left: bounds.x, top: bounds.y, width: bounds.w, height: bounds.h)
                  |     +-- CustomPaint: stroke 1.5px primary
                  |     +-- Positioned(top: -20): Badge(widgetType)
                  |
                  +-- (Info Panel placeholder — arrives in L05)
```

ASCII — enable/disable gesture passthrough:

```text
isEnabled == false:
  App gestures ──> ListView scrolls normally ──> Overlay Listener inactive (deferToChild)

isEnabled == true:
  Pointer down at (x,y) ──> SelectionEngine.selectAt(x,y) ──> ValueNotifier -> Highlight
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/src/overlay/agentation_overlay.dart` | `AgenationOverlay` widget |
| `lib/src/overlay/agentation_controller.dart` | `AgenationController` (`isEnabled`, `selected`, wraps `SelectionEngine`) |
| `lib/src/overlay/selection_highlight.dart` | `SelectionHighlight` + `SelectionHighlightPainter` |
| `lib/src/overlay/activation_toggle.dart` | Compact M3 toggle chip/FAB |
| `lib/src/overlay/tokens.dart` | `AgentationColors` `ThemeExtension` + spacing constants |
| `test/overlay/*_test.dart` | Activation, highlight, controller tests + golden |

### Classes

| Class | File | Responsibility |
|-------|------|----------------|
| `AgenationController` | `agentation_controller.dart` | `ValueNotifier<bool> isEnabled`; `ValueNotifier<SelectionResult?> selected` (exposed or proxied from engine); `toggle()/enable()/disable()`; disposes |
| `AgenationOverlay` | `agentation_overlay.dart` | Wraps child in `OverlayPortal`; installs `Listener` only when `isEnabled==true`; wires controller + engine |
| `SelectionHighlight` | `selection_highlight.dart` | Pure widget `({RectInfo? bounds, String label})`; renders stroke + badge; `const` capable |
| `SelectionHighlightPainter` | `selection_highlight.dart` | `CustomPainter` for 1.5px stroke + optional corner brackets |
| `ActivationToggle` | `activation_toggle.dart` | Stateless button; `onPressed: controller.toggle` |
| `AgentationColors` | `tokens.dart` | `ThemeExtension<AgentationColors>` { selectionStroke, badgeBg } |

### Functions / APIs

```dart
// controller
class AgentationController extends ChangeNotifier {
  AgentationController({SelectionEngine? engine, WidgetResolver? resolver});
  ValueNotifier<bool> get isEnabled;
  ValueNotifier<SelectionResult?> get selected;
  void toggle();
  void enable();
  void disable();
  @override void dispose();
}

// overlay
class AgentationOverlay extends StatefulWidget {
  const AgentationOverlay({super.key, required this.child, AgentationController? controller});
  factory AgentationOverlay.wrap({required Widget child, AgentationController? controller});
  Widget get child;
}

// highlight
class SelectionHighlight extends StatelessWidget {
  const SelectionHighlight({super.key, required this.bounds, required this.label});
  final RectInfo? bounds;
  final String label; // widgetType
}
```

### Design — Instrument aesthetic

- Palette: `surfaceContainerHigh` panel/toggle base, `primary` stroke/active — per `ui-context.md:Colors`. Type: Inter 500 labels inside highlight badge, JetBrains Mono for file:line elsewhere. Shape: 12 radius toggle, 8 radius badge — no gradients, no mesh, no decorative blur.
- Motion: `AnimatedOpacity` for enable fade, `AnimatedPositioned` 80ms for highlight move — `disableAnimations` disables.

### Differentiation

- `Flan`/`Widgetation` use heavier overlays with fills/drag handles even in inspect mode; this V1 overlay is **stroke-only + badge + toggle**, satisfying `design-statement.md:38-41` minimal chrome so the app remains readable.

### Testing & Analyze Notes

- Run `flutter analyze` → No issues; `flutter test test/overlay/` → 6+; `flutter test test/overlay/highlight_golden_test.dart --update-goldens` on CI baseline.
- Manual: `flutter run` a minimal scaffold + toggle + tap → highlight precise.

### How to verify

```ps
flutter analyze
flutter test test/overlay/overlay_activation_test.dart
```

