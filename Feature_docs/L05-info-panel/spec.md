# Feature Specification: L05 — Info Panel

**Feature Branch**: `L05-info-panel`

**Created**: 2026-08-28

**Status**: Draft — depends on L00–L04 (needs highlight + SelectionResult + WidgetFacts)

**Input**: `design-statement.md:43-51` Information panel + `spec.md:FR-004–FR-007` + `architecture.md:3.4` Context Collector (hierarchy/bounds/source) + `decisions.md:ADR-009` (optional source)

## User Scenarios & Testing

### User Story 1 — See widget identity + source + geometry + hierarchy in a panel (Priority: P1)

As the developer after tapping a widget, I see a bottom sheet / side panel with: `Widget: ElevatedButton`, `Source: lib/screens/home.dart:143:12`, `Bounds: x=32 y=540 w=320 h=52`, `Hierarchy: Scaffold → Column → Card → ElevatedButton` — so I instantly know *what* I pointed at.

**Why P1**: `design-statement.md:43-51` + `spec.md:FR-004–FR-007` — the panel is the "understand" step of `Inspect → Select → Understand → Annotate → Export`.

**Independent Test**: Select an `ElevatedButton("Get Started")` → `find.text("Widget: ElevatedButton")` exists, `find.textContaining("lib/screens/home.dart:143")` exists, `find.textContaining("Hierarchy")` shows 4 levels.

**Acceptance Scenarios**:
1. **Given** a selected widget with full metadata, **When** panel renders, **Then** it shows widgetType/runtimeType, source file:line:column, bounds x/y/w/h, and root→leaf hierarchy (see L01 bounded to 12)
2. **Given** hierarchy of depth 4, **When** displayed, **Then** order is root→leaf with indentation (`Scaffold` at top, `ElevatedButton ◄ selected` at bottom, bold/primary)

---

### User Story 2 — Gracefully handle missing source (Priority: P1)

As the developer inspecting a framework widget in release or a `RenderObject` without creation location, I see "Source unavailable in this build" in styled error color, not a blank or a crash.

**Why P1**: `spec.md:FR-005` + `decision.md:ADR-009`.

**Independent Test**: Select a framework `RenderFlex` element where `sourceLocation == null` → `find.text("Source unavailable")` exists, `find.textContaining(".dart:")` does not.

**Acceptance Scenarios**:
1. **Given** `sourceLocation == null`, **When** panel renders Source row, **Then** it shows "Source unavailable in this build" with `colorScheme.error` and no file link
2. **Given** `sourceLocation` present, **When** panel renders, **Then** it shows `file:line:column` with mono font

---

### User Story 3 — Scrollable, not modally blocking (Priority: P2)

As the developer, I can still see the underlying app behind the panel; the panel can be scrolled if hierarchy/runtime details are long, and it doesn't block inspection of the next widget (tapping another widget updates the same panel).

**Why P2**: `design-statement.md:03-15` — low cognitive load; panel is chrome, not a modal prison.

**Independent Test**: With long hierarchy (8 levels) + many properties, `SingleChildScrollView` scrolls; tapping a second widget updates panel text without closing it.

**Acceptance Scenarios**:
1. **Given** panel open on widget A, **When** tapping widget B, **Then** panel updates to B's data without explicit close/reopen
2. **Given** panel scrolled mid-content, **When** selecting a new widget, **Then** scroll position resets to top (so developer sees widget type first)

---

### Edge Cases

- Extremely long `properties` map (>20 entries) — `ListView` inside panel capped height with scrolling, not expanding to full screen.
- Very small screen (e.g., 320px width) — panel is `DraggableScrollableSheet` or `BottomSheet` with constraints; text wraps, mono file paths ellipsis.
- `text` property missing — panel shows runtime details section but omits Text row (no "null" string).
- `bounds == null` — Geometry row shows "Bounds unavailable" with tooltip explain (non-RenderBox).

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide `InfoPanel` widget `({required SelectionResult? result, required DeveloperIntent? note, required VoidCallback onCopy})` — presentational, no resolver logic inside.
- **FR-002**: Panel MUST render 5 sections in fixed order: **Widget** (type + runtimeType), **Source** (file:line:column or unavailable), **Geometry** (x/y/w/h or unavailable), **Hierarchy** (root→leaf, selected row bold/primary), **Runtime Details** (text/key/semantics/properties if present). Section headings: Inter 500, values: JetBrains Mono 400.
- **FR-003**: Hierarchy MUST respect L01 cap (12) and visually indicate selected tail (e.g., `└── ElevatedButton ◄`).
- **FR-004**: Panel MUST be shown via `showModalBottomSheet` / `DraggableScrollableSheet` or `CompositedTransformFollower` side panel — chosen to be non-blocking and responsive (bottom sheet on narrow, side panel on ≥900px wide per `LayoutBuilder`).
- **FR-005**: Panel MUST be scrollable (`SingleChildScrollView` or `CustomScrollView`) and not exceed 60% of viewport height on mobile, 100% on side-panel layout.
- **FR-006**: Panel MUST use `Theme.of(context).colorScheme` + `ThemeExtension` — no hardcoded colors; "unavailable" in `colorScheme.error`.
- **FR-007**: Panel MUST expose `InfoPanelContent` pure data object for golden/widget tests without needing overlay wiring.
- **FR-008**: Panel MUST include a placeholder slot for **Feedback field** (L06) and **Copy CTA** (L07) — they arrive later but panel reserves the space with dividers.

### Key Entities

- **InfoPanel**: container widget — switches between bottom-sheet vs side-panel via `LayoutBuilder`.
- **InfoRow**: `({required String label, required String value, bool isUnavailable})` — reusable label/value row.
- **HierarchyTree**: `({required List<String> path, required String selected})` — renders indented tree.
- **UnavailableLabel**: styled error row for source/geometry unavailable.

## Success Criteria

- **SC-001**: Widget tests: full panel, source-null panel, hierarchy cap, bounds-null — 6+ cases; `flutter analyze` → No issues.
- **SC-002**: Golden test for panel in both states (full vs unavailable) at 390×844 and 800×600.
- **SC-003**: No hardcoded color literals in `lib/src/overlay/info_panel.dart` (grep `Color(0x` returns 0).
- **SC-004**: Tapping a second widget updates the same open panel (live `ValueListenableBuilder` on `controller.selected`).

## Assumptions

- Panel content is derived synchronously from `SelectionResult` + `ContextModel` — no async source fetch in V1 (`spec.md:FR-005` is sync).
- Feedback + Copy slots are empty containers in L05; functional in L06/L07.

---

## Technical Design

### Languages & Versions

| Layer | Language | Version |
|-------|----------|---------|
| Panel UI | Dart 3.12.2 / Flutter 3.44.9 | `material.dart`, `widgets.dart` |
| Typography | GoogleFonts? optional | Prefer built-in Inter/JetBrains Mono fallbacks; `google_fonts` only if design requires |

### Folder Structure

```text
lib/
├── src/
│   ├── context/                  # L01
│   ├── resolver/                 # L02
│   ├── selection/                # L03
│   └── overlay/                  # L04 (+ NEW in L05)
│       ├── agentation_overlay.dart
│       ├── selection_highlight.dart
│       ├── activation_toggle.dart
│       ├── info_panel.dart                # NEW — container + layout switching
│       ├── widgets/
│       │   ├── info_row.dart              # InfoRow
│       │   ├── hierarchy_tree.dart        # HierarchyTree
│       │   └── unavailable_label.dart     # UnavailableLabel
│       └── tokens.dart
test/
├── overlay/
│   ├── info_panel_test.dart
│   ├── info_panel_golden_test.dart
│   └── hierarchy_tree_test.dart
```

ASCII — panel wireframe (mobile bottom sheet, from `ui-context.md:Info panel`):

```text
┌──────────────────────────────────────────────┐  <- overlay bottom sheet (60% height, RoundedTop 16)
│ Handle ────  32px grab bar                    │
│ ┌ Widget ────────────────────────────────┐   │
│ │ Widget:  ElevatedButton                │   │
│ │ Runtime: ElevatedButton                │   │
│ └────────────────────────────────────────┘   │
│ ──────────────────────────────────────────    │ Divider
│ ┌ Source ────────────────────────────────┐   │
│ │ File:   lib/screens/home.dart:143:12  │   │ <- mono, or "Source unavailable in this build" (error)
│ └────────────────────────────────────────┘   │
│ ──────────────────────────────────────────    │
│ ┌ Geometry ──────────────────────────────┐   │
│ │ X: 32  Y: 540  W: 320  H: 52           │   │
│ └────────────────────────────────────────┘   │
│ ──────────────────────────────────────────    │
│ ┌ Hierarchy ─────────────────────────────┐   │
│ │ Scaffold                              │   │
│ │  └─ Column                             │   │
│ │     └─ Card                            │   │
│ │        └─ ElevatedButton ◄ selected    │   │ <- primary/bold tail
│ └────────────────────────────────────────┘   │
│ ──────────────────────────────────────────    │
│ ┌ Runtime Details ───────────────────────┐   │
│ │ Text:  Get Started                     │   │
│ │ Key:   [MyKey]                        │   │
│ │ Color: ... (if properties)            │   │
│ └────────────────────────────────────────┘   │
│ ──────────────────────────────────────────    │
│ ┌ Feedback (placeholder for L06) ────────┐   │
│ │ [ Make this more rounded...      ]    │   │ <- empty box in L05, functional in L06
│ └────────────────────────────────────────┘   │
│ [ Copy Markdown ]            [ • screenshot]  │ <- placeholder for L07 CTA
└──────────────────────────────────────────────┘

Wide layout (≥900px):
  Scaffold -> Row [ App flex | InfoPanel 380px side panel ]
```

ASCII — data binding:

```text
SelectionResult (from L03)
        |
        v
AgenationController.selected (ValueNotifier)
        |
        v
InfoPanel (ValueListenableBuilder)
        |
        +--> InfoRow(label:"Widget", value:facts.widgetType)
        +--> InfoRow(label:"Source", value:sourceString or UnavailableLabel)
        +--> InfoRow(label:"Geometry", value:boundsString)
        +--> HierarchyTree(path: facts.hierarchy)
        +--> RuntimeDetails (text/key/properties)
        +--> (L06) Feedback slot
        +--> (L07) Copy slot
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/src/overlay/info_panel.dart` | `InfoPanel` container — bottomSheet/sidePanel switching |
| `lib/src/overlay/widgets/info_row.dart` | `InfoRow` + label/value layout |
| `lib/src/overlay/widgets/hierarchy_tree.dart` | `HierarchyTree` indented rendering |
| `lib/src/overlay/widgets/unavailable_label.dart` | Styled unavailable row |
| `test/overlay/info_panel_test.dart` | Full/partial/missing cases |
| `test/overlay/info_panel_golden_test.dart` | Goldens for full vs unavailable + responsive |

### Classes

| Class | File | Responsibility |
|-------|------|----------------|
| `InfoPanel` | `info_panel.dart` | `const InfoPanel({result, onCopyPlaceholder})`; `LayoutBuilder` to pick sheet vs side panel; wraps `InfoPanelContent` |
| `InfoPanelContent` | `info_panel.dart` | Pure content widget `({required WidgetFacts facts, RectInfo? bounds, bool showFeedbackPlaceholder})`; no controller |
| `InfoRow` | `info_row.dart` | `const InfoRow({required String label, required String value, bool unavailable})`; label Inter 500, value JetBrains Mono |
| `HierarchyTree` | `hierarchy_tree.dart` | `const HierarchyTree({required List<String> path})`; builds `Column` of indented rows; tail bold/primary |
| `UnavailableLabel` | `unavailable_label.dart` | `Text("Source unavailable in this build", style: error)` |

### Functions / APIs

```dart
class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.result});
  final SelectionResult? result; // null => no selection placeholder
}

class InfoPanelContent extends StatelessWidget {
  const InfoPanelContent({super.key, required this.facts, this.bounds, this.hierarchy});
  final WidgetFacts facts;
  final RectInfo? bounds;
  final List<String> hierarchy;
}

class HierarchyTree extends StatelessWidget {
  const HierarchyTree({super.key, required this.path, required this.selected});
  String buildIndentedTree(); // helper for tests: returns indented string
}
```

### Design — Instrument aesthetic (key)

- Colors: `surfaceContainerHigh` sheet/side panel, `outlineVariant` dividers, `error` unavailable, `primary` selected tail — no decorative gradients. Typography: Inter for labels, JetBrains Mono for file:line values — per `ui-context.md:Typography`.
- Spacing: 12 between sections, 8 between rows via `tokens.dart` constants. Shape: 16 top radius sheet.

### Differentiation

- `Widgetation` shows a dense JSON/diagnostic dump; this panel is **curated**: 5 sections, hierarchy tree, mono values, bounded — "precision + low cognitive load" per `design-statement.md:03-15`.

### Testing & Analyze Notes

- Run `flutter analyze` → No issues; `flutter test test/overlay/info_panel*` → 6+ cases; goldens with `flutter test --update-goldens` baseline commit.

### How to verify

```ps
flutter analyze
flutter test test/overlay/info_panel_test.dart
```

