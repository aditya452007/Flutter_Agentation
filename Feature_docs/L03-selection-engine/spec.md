# Feature Specification: L03 — Selection Engine

**Feature Branch**: `L03-selection-engine`

**Created**: 2026-08-28

**Status**: Draft — depends on L00, L01, L02 (needs WidgetFacts + resolvers)

**Input**: `architecture.md:3.2` Selection Engine + `architecture.md:87-93` hit-testing leverage + `spec.md:FR-002/FR-003/FR-006` + `build-instructions.md:Architecture Requirement` (reusable normalized model)

## User Scenarios & Testing

### User Story 1 — Tap selects the deepest widget under the pointer (Priority: P1)

As the developer in inspection mode, I tap on a button nested inside a `Card`, and the tool selects **the button**, not the card behind it.

**Why P1**: Core of "point at something in a running UI" (`context.md:11-13`). If hit-testing picks the wrong layer, all later context is wrong.

**Independent Test**: Pump `Stack(Card(size 200) > ElevatedButton(size 120))` ; call `engine.selectAt(Offset(50,50))` inside button bounds → `selectedElement.widget is ElevatedButton`.

**Acceptance Scenarios**:
1. **Given** inspection mode enabled and a nested button visible, **When** `selectAt(offsetInsideButton)`, **Then** `result.widgetType == "ElevatedButton"` (not `"Card"`)
2. **Given** tap outside any rendered widget (e.g., padding gap), **When** `selectAt(offset)`, **Then** `result == null` (no crash, no selection)

---

### User Story 2 — Works across platforms without per-OS logic (Priority: P2)

As the package, I want the same `SelectionEngine` to work on Android, iOS, Web, Windows, macOS, Linux without branching `if (Platform.isAndroid)` in business logic.

**Why P2**: `architecture.md:56-65` — core model platform-neutral; platform adapters only when runtime requires.

**Independent Test**: Run the same `selectAt` widget test on `flutter test` (which simulates all as a single platform) and on `flutter test --platform chrome` style — both pick correctly; no platform-conditional code introduced.

**Acceptance Scenarios**:
1. **Given** Engine code, **When** grepped for `Platform.is*` or `TargetPlatform` in `lib/src/selection/`, **Then** none found (enforced by review + `analysis_options`)

---

### User Story 3 — Graceful handling of unavailable / offscreen (Priority: P2)

As the overlay, when `selectAt` finds no element or the element has no `RenderBox`, I want a `null` / `SelectionResult.empty` rather than a throw, so overlay can show "no selection."

**Why P2**: `spec.md:Non-Functional Reliability` — selection should work with deeply nested trees and degraded cases.

**Independent Test**: Call `selectAt(Offset(-1000,-1000))` offscreen → `null`; find an element whose RO is not `RenderBox` → `bounds == null` but `widgetType` still returned.

**Acceptance Scenarios**:
1. **Given** `selectAt` offscreen, **When** result is null, **Then** overlay clears highlight without error
2. **Given** element with non-RenderBox RO, **When** `selectAt` returns, **Then** `result.bounds == null && result.widgetType != null`

---

### Edge Cases

- Overlapping `GestureDetector` / `AbsorbPointer` — hit-testing must respect Flutter's `HitTestResult` order, not skip translucent hit targets.
- `RepaintBoundary` / `OverlayPortal` — ensure traversal includes overlay entries.
- Rapid pointer moves (drag over multiple widgets) — selection updates via `selectAt` called on pointer move, not only on tap end; debouncing not required in V1.
- Inspect mode disabled — `selectAt` must be a no-op (caller checks `enabled` first; engine itself may remain inert).

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide `SelectionEngine` class with `SelectionResult? selectAt(Offset globalOffset, {BuildContext? context})` and an overload `selectAtWithContext(BuildContext context, Offset globalPosition)`.
- **FR-002**: Selection MUST leverage Flutter's existing hit-testing: `RenderObject.hitTest(HitTestResult, Offset)` via `WidgetsBinding.instance.hitTest(result, offset)` or `RenderBox.hitTest` on the root `RenderView` — **not** a custom bounding-box loop over all elements.
- **FR-003**: Engine MUST return the **deepest** hittable `Element` (the last in `HitTestResult.path` that maps to an `Element`) — mirroring DevTools Inspector's logic, not merely the `RenderObject`.
- **FR-004**: Result MUST contain at minimum: `Element element`, `WidgetFacts facts` (via L02 `WidgetResolver`), `RectInfo? bounds` (global), and `Offset localOffset` (alias for input). Helpers `bool get hasSource` derived.
- **FR-005**: Engine MUST NOT fabricate `SourceLocation` — that remains resolver's job (`decision.md:ADR-009`). Engine only forwards `WidgetFacts` as-is.
- **FR-006**: Engine MUST expose `Stream<SelectionResult?>? onSelectionChanged` or a `ValueNotifier<SelectionResult?> selected` so the overlay can react (choose one — see Classes table; prefer `ValueNotifier` for simplicity per `build-instructions.md:155`).
- **FR-007**: Engine MUST be synchronous and `O(hitTest)` — no network, no isolate, no `Future`.
- **FR-008**: Engine MUST NOT depend on external state-management packages — pure `ChangeNotifier` / `ValueNotifier` (keep deps minimal).

### Key Entities

- **SelectionResult**: `{ Element element, WidgetFacts facts, RectInfo? bounds, Offset globalOffset }` — immutable, nullable `bounds` allowed.
- **SelectionEngine**: hit-testing + resolver delegation + `ValueNotifier<SelectionResult?>`.
- **HitTestAdapter** (optional): tiny interface to swap `WidgetsBinding.hitTest` in tests if needed — but default impl calls the framework directly.

## Success Criteria

- **SC-001**: Widget tests for nested selection, offscreen, non-RenderBox, overlap — 6+ cases in `test/selection/selection_engine_test.dart` pass.
- **SC-002**: `flutter analyze` → No issues; `flutter test test/selection/` → all green.
- **SC-003**: No `Platform.*` branching in `lib/src/selection/` (grep check).
- **SC-004**: Manual verification in a pumped app: tapping two overlapping tappables selects the front-most (deepest) one.

## Assumptions

- `WidgetsBinding.instance.hitTest` is available in tests via `WidgetTester`; engine uses that in production as well.
- Inspector mode is gated by an external `bool enabled` flag (owned by Overlay controller L04) — engine may be called only when enabled, but remains safe if called when disabled.

---

## Technical Design

### Languages & Versions

| Layer | Language | Version |
|-------|----------|---------|
| Engine | Dart 3.12.2 / Flutter 3.44.9 | `flutter/widgets.dart`, `flutter/rendering.dart`, `flutter/gestures.dart` |
| State | `ValueNotifier<T>` / `ChangeNotifier` | No Riverpod/Bloc in V1 |

### Folder Structure

```text
lib/
├── src/
│   ├── context/               # L01 models
│   ├── resolver/              # L02 resolvers
│   └── selection/             # NEW
│       ├── selection_engine.dart
│       ├── selection_result.dart
│       └── hit_test_adapter.dart   # optional tiny adapter for testability
test/
├── selection/
│   ├── selection_engine_test.dart
│   └── hit_test_adapter_test.dart
```

ASCII — flow from tap to model:

```text
 Pointer at (x,y) global
        |
        v
 SelectionEngine.selectAt(offset)
        |
        +--> WidgetsBinding.hitTest(result, offset)
        |         |
        |         v
        |    HitTestResult.path = [RenderView, RenderFlex, RenderBox(ElevatedButton), ...]
        |         |
        |         v
        +--> Resolve deepest Element from path (via RenderObject -> Element map)
        |
        +--> WidgetResolver.resolve(element) -> WidgetFacts
        |
        +--> BoundsExtractor.rect(element) -> RectInfo? (global)
        |
        v
 SelectionResult{ element, facts, bounds, globalOffset }
        |
        v
 ValueNotifier<SelectionResult?>.value = result  --> Overlay listens
```

ASCII — hit-test ordering:

```text
Stack (hitTest traversal front->back)
  +-- Back:  Scaffold
  +-- Mid:   Card (200x100)
  +-- Front: ElevatedButton (120x52)  <-- pointer inside => HitTestResult path ends here
                                          deepest Element = ElevatedButton
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/src/selection/selection_engine.dart` | `SelectionEngine` + `ValueNotifier<SelectionResult?>` |
| `lib/src/selection/selection_result.dart` | Immutable `SelectionResult` + `SelectionResult.empty` sentinel |
| `lib/src/selection/hit_test_adapter.dart` | Optional: `abstract class HitTestAdapter` + `FlutterHitTestAdapter` implementation |
| `test/selection/selection_engine_test.dart` | Nested/overlap/offscreen/non-RenderBox tests |

### Classes

| Class | File | Responsibility |
|-------|------|----------------|
| `SelectionResult` | `selection_result.dart` | Value object `{element, facts, bounds, globalOffset}`; `bool get hasBounds`; `toString()` |
| `SelectionEngine` | `selection_engine.dart` | `SelectionResult? selectAt(Offset)`; holds `ValueNotifier<SelectionResult?> selected`; injects `WidgetResolver` + `HitTestAdapter` |
| `HitTestAdapter` | `hit_test_adapter.dart` | `HitTestResult hitTest(Offset globalOffset)` — swappable for tests; default delegates to framework |

### Functions / APIs

```dart
// selection_result.dart
@immutable
class SelectionResult {
  const SelectionResult({
    required Element element,
    required WidgetFacts facts,
    required Offset globalOffset,
    required RectInfo? bounds,
  });
  Element get element;
  WidgetFacts get facts;
  RectInfo? get bounds;
  Offset get globalOffset;
  bool get hasBounds => bounds != null;
}

// selection_engine.dart
class SelectionEngine extends ChangeNotifier {
  SelectionEngine({WidgetResolver? resolver, HitTestAdapter? hitTest});
  ValueNotifier<SelectionResult?> get selected; // public notifier
  SelectionResult? selectAt(Offset globalOffset, {BuildContext? context});
  void clear();
  void dispose();
}

// hit_test_adapter.dart
abstract class HitTestAdapter {
  HitTestResult hitTest(Offset globalOffset);
}
class FlutterHitTestAdapter implements HitTestAdapter {
  @override
  HitTestResult hitTest(Offset offset) => WidgetsBinding.instance.hitTest(...);
}
```

### Design Notes

- **No AI slop**: engine has no UI — correctness is precision (deepest hittable, not middle).
- Keep deps minimal — no `rxdart`, no `bloc`; `ValueNotifier` suffices.

### Differentiation

- `Widgetation` wraps hit-testing with additional gesture arenas; this engine stays **one thin call to `WidgetsBinding.hitTest`** + `WidgetResolver` — fewer assumptions, easier to extend to V2 rectangle/arrow without rework.

### Testing & Analyze Notes

- Run `flutter analyze` → No issues; `flutter test test/selection/` → 6+ cases.
- Tests pump real widget trees and use `tester.getCenter(find.byType(ElevatedButton))` as offset source — representative per `architecture.md:Testing Strategy`.

### How to verify

```ps
flutter analyze        # No issues
flutter test test/selection/selection_engine_test.dart
```

