# Feature Specification: L08 — Minimal Demo App

**Feature Branch**: `L08-demo-app`

**Created**: 2026-08-28

**Status**: Draft — depends on L00–L07 (full pipeline must exist before a demo can validate it)

**Input**: `spec.md:Acceptance Test` + `build-instructions.md:Version 1 Scope` (demo) + `architecture.md:31-40` Testing Strategy + `context/progress-tracker.md:Platform Priority All 6 equally` (your answer) + user request "create a dummy like windows or something Android 5 so that we can test our code — minimal demo to test"

## User Scenarios & Testing

### User Story 1 — Acceptance demo covers multi-type + nested selection (Priority: P1)

As the reviewer, I run `example` and can tap a button inside a Card inside a Column inside a Scaffold and see correct widget identity + hierarchy, plus repeat for a switch, a text field, and a list tile — proving selection isn't hard-coded to one widget.

**Why P1**: `spec.md:Acceptance Test` — "selecting multiple different widget types, selecting nested widgets, displaying source when available, bounds, hierarchy, feedback, Markdown, copying, graceful when unavailable." If the demo only has one widget, V1 is incomplete (`build-instructions.md:Completion Criteria`).

**Independent Test**: `flutter run -d chrome` (web) or any of the 6 platforms → enable Inspect → tap ElevatedButton → panel shows `ElevatedButton` → select nested Checkbox → panel updates → so on for 5+ types.

**Acceptance Scenarios**:
1. **Given** demo running, **When** selecting `ElevatedButton` → `Card` → `Scaffold` hierarchy chain, **Then** each selection shows distinct widget types and correct bounds
2. **Given** demo running, **When** selecting a deeply nested widget (3+ ancestors), **Then** hierarchy displays correctly with `◄ selected`

---

### User Story 2 — Runs on all 6 platforms (Priority: P1)

As the developer validating "All 6 equally" platform priority, I can run the same demo on Android, iOS, Web, Windows, macOS, Linux without branching app logic — proving `architecture.md:56-65` platform-neutral core.

**Why P1**: Your explicit answer: V1 acceptance blocks on all 6. Demo must be multi-platform from day 0.

**Independent Test**: `flutter build web` + `flutter build apk` + `flutter build windows/macos/linux/ios` all succeed; manual spot-check on at least Web + one desktop shows highlight alignment correct.

**Acceptance Scenarios**:
1. **Given** `example/` with no `Platform.is*` branching, **When** building each target, **Then** all builds succeed and `AgenationOverlay.wrap` still highlights
2. **Given** demo on a small (Android 320dp) and large (Desktop 1280px) viewport, **When** panel is shown, **Then** it switches bottom-sheet ↔ side panel via `LayoutBuilder` (L05 design)

---

### User Story 3 — Dummy breadth proves degraded cases (Priority: P2)

As the panel, I can show "Source unavailable" gracefully — the demo must include at least one widget where source is likely framework-owned or not debug-resolvable, so `spec.md:FR-005` graceful path is observable without needing a release build.

**Why P2**: `spec.md:FR-005` says show unavailable rather than fabricate.

**Independent Test**: Demo includes a bare `Divider` / `RenderFlex` heavy area or a `const` framework widget that resolves with `sourceLocation == null` in some configs — panel shows unavailable text (not crash).

**Acceptance Scenarios**:
1. **Given** selecting a framework-heavy region, **When** inspecting source row, **Then** panel shows "Source unavailable in this build" in error color and remaining sections remain populated

---

### Edge Cases

- Demo deep hierarchy (>12) truncated with ellipsis — covered by L02 cap + L05 render.
- Demo uses `ListView` + `Card` nesting that exercises `RenderBox` vs non-box mixed children.
- Hot reload while inspection enabled — selection re-resolves bounds without stale highlight (L04 metric listener).
- `flutter analyze` on `example/` must also be green — example isn't analysis-exempt.

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide `example/` Flutter app (`example/pubspec.yaml` depending on `flutter_agnetation` via `path: ../`) with `example/lib/main.dart` entry — minimal, not a Windows 11 clone — named `Agenation Demo`.
- **FR-002**: Demo MUST contain at least 5 distinct widget types across 2-3 screens: `Scaffold + AppBar + ElevatedButton + Card + ListTile + Checkbox/Switch + TextField + Divider + Icon`. Nested at least 3 deep for hierarchy tests (e.g., `Scaffold > Column > Card > Column > ElevatedButton`).
- **FR-003**: Demo MUST wrap entire app with `AgenationOverlay.wrap(child: MaterialApp(...))` and expose `AgenationController` so L04–L07 overlay chrome is visible.
- **FR-004**: Demo MUST have 2 routes (`/` and `/details`) via `MaterialApp.routes` (or `go_router` if L04 used it, but demo stays `MaterialApp` simple to avoid extra deps) — proves non-single-screen selection still works after navigation.
- **FR-005**: Demo MUST use **Material 3 instrument aesthetic only** — `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey))`, `surfaceContainerHigh` cards, no purple gradient/mesh — per your anti-AI-slop rule and `design-statement.md:03-15`.
- **FR-006**: `example/pubspec.yaml` MUST pin `sdk: ">=3.12.2 <4.0.0"` + `flutter: ">=3.44.9"` matching root, and depend on `flutter_agnetation` via path. No extra deps unless strictly needed (e.g., no `go_router` unless overlay needs it).
- **FR-007**: `example/analysis_options.yaml` MUST extend `../analysis_options.yaml` (or at least `package:very_good_analysis`) so demo also has strict analyze.
- **FR-008**: Demo MUST include a README note `example/README.md` with `flutter run` + `flutter build` commands for all 6 targets and how to use Inspect → Select → Feedback → Copy.
- **FR-009**: Demo MUST NOT call AI, network, or MCP — same V1 invariant as the package.

### Key Entities

- **DemoApp**: `MaterialApp(useMaterial3:true)` → `HomeScreen` → `DetailsScreen`.
- **HomeScreen**: `Scaffold + AppBar("Agenation Demo") + ListView` with 8+ Cards/tiles/buttons/sliders to give dense selection targets.
- **DetailsScreen**: single `Card` with `ElevatedButton("Get Started")` + hierarchy depth showcase.

## Success Criteria

- **SC-001**: `flutter analyze` → No issues in both root and `example/` (very_good_analysis strict).
- **SC-002**: `flutter test` (package) + `flutter test` in `example` (if any demo tests) pass; `flutter build web` succeeds; spot `flutter build apk/windows/macos` green (CI to verify).
- **SC-003**: Manual acceptance (from `spec.md:Acceptance Test`): enable → tap 5 types → see correct identity/source?/bounds/hierarchy → type note → generate Markdown → copy → paste into editor and see expected sections.
- **SC-004**: No hardcoded platform `if (Platform.isX)` branching in demo — verified by grep.

## Assumptions

- Demo is **minimal**, not a Windows 11 Settings clone nor a full Material catalog — per your "choose a minimal demo to test" answer. Breadth (5+ types, 2 routes, nested) beats visual richness.
- Screenshot/visual-evidence integration in demo may remain boolean (no real screenshot bytes in V1) — L07 exporter já handles `screenshotAvailable:false`.

---

## Technical Design

### Languages & Versions

| Layer | Language | Version |
|-------|----------|---------|
| Demo | Dart 3.12.2 / Flutter 3.44.9 | `material.dart`, `widgets.dart` |
| Build | `flutter build web/apk/windows/macos/linux/ios` | All 6 as non-negotiable per your answer |

### Folder Structure (demo only)

```text
example/
├── lib/
│   └── main.dart                  # DemoApp + HomeScreen + DetailsScreen (≤300 lines)
├── test/                          # optional — one smoke test that pumps DemoApp + verifies overlay mounts
├── pubspec.yaml                   # path: ../ flutter_agnetation + very_good_analysis dev
├── analysis_options.yaml          # include: ../analysis_options.yaml  (or package:very_good_analysis)
└── README.md                      # how to run + platform notes

# package lib/ itself (from L00–L07) now has:
lib/
├── src/
│   ├── context/                  # L01 models
│   ├── resolver/                 # L02
│   ├── selection/                # L03
│   ├── overlay/                  # L04/L05 (overlay + info panel + feedback + copy)
│   ├── annotation/               # L06
│   └── exporter/                 # L07
└── agentation.dart               # barrel
```

ASCII — demo screen composition (Home — dense targets for hit-testing):

```text
┌─ AppBar("Agenation Demo") ───────────────────────────────┐  <- Material 3, surfaceContainer
│  Actions: [Toggle Inspect OFF/ON]  (from L04 chrome)    │
├──────────────────────────────────────────────────────────┤
│ ListView (padding 16)                                    │
│  ┌─ Card (surfaceContainerLow) ───────────────────────┐ │
│  │  ListTile( leading: Icon, title: "Account",          │ │
│  │           subtitle: "Manage profile" )             │ │
│  │  Row[ Chip("Soon") , Switch(value:true) ]         │ │
│  └──────────────────────────────────────────────────────┘ │
│  ┌─ Card ───────────────────────────────────────────┐ │
│  │  Padding 16: Column                              │ │
│  │    Text("Quick actions", style: titleSmall)     │ │
│  │    Row[ ElevatedButton("Get Started")            │ │
│  │        , OutlinedButton("Details ->") ]         │ │
│  │    TextField(hint:"Developer note test")        │ │
│  └──────────────────────────────────────────────────────┘ │
│  ┌─ Card ───────────────────────────────────────────┐ │
│  │  CheckboxListTile("Enable sync")                 │ │
│  │  Divider                                         │ │
│  │  ListTile( Icon + "Storage" ) ×3 in Column       │ │
│  └──────────────────────────────────────────────────────┘ │
│ Tap any of these while Inspect is ON → InfoPanel     │ │  <- bottom sheet or side panel
│ updates live; Feedback + Copy are functional (L06/07)│ │
└──────────────────────────────────────────────────────────┘

Details screen (/details) — depth showcase:
  Scaffold > Center > Card > Column > ElevatedButton  (hierarchy 5 deep)
```

ASCII — overlay wiring in demo:

```text
AgenationOverlay.wrap(
  child: MaterialApp(
    home: HomeScreen,
    routes: { "/details": (_) => DetailsScreen() }
  )
)
        |
        +-- AgentationController(isEnabled, selected, engine, annotation)
        +-- SelectionEngine + WidgetResolver
        +-- InfoPanel (via overlay bottom sheet / side panel)
             +-- FeedbackField (binds AnnotationManager)
             +-- CopyButton (binds MarkdownExporter + ClipboardService)
```

### Files to Create

| File | Purpose |
|------|---------|
| `example/lib/main.dart` | `void main() => runApp(DemoApp)` + `DemoApp/ HomeScreen/ DetailsScreen` |
| `example/pubspec.yaml` | `name: example` + `dependencies: flutter_agnetation: path: ../` + `very_good_analysis` |
| `example/analysis_options.yaml` | `include: ../analysis_options.yaml` (or `very_good_analysis`) so demo inherits strict |
| `example/README.md` | How to `flutter run`/`build` on all 6 platforms + Inspect → Select → Feedback → Copy |
| `example/test/demo_smoke_test.dart` | Pumps `DemoApp`, taps a Card's button, asserts panel appears (optional but recommended) |

### Classes

| Class | File | Responsibility |
|-------|------|----------------|
| `DemoApp` | `main.dart` | `MaterialApp(useMaterial3:true, routes:{"/", "/details"})`, wraps with `AgenationOverlay.wrap` |
| `HomeScreen` | `main.dart` | `Scaffold + ListView` with 5+ type targets, 3-deep nesting |
| `DetailsScreen` | `main.dart` | Single deep-hierarchy card + "Back" — validates cross-route selection |

No other classes — keep demo <300 lines total, per `code-standards.md` single-purpose rule.

### Design — Instrument, not AI slop

- Theme: `ColorScheme.fromSeed(seedColor: Colors.blueGrey)` (cool neutral), not purple/violet seed. Cards: `surfaceContainerLow`, sheets: `surfaceContainerHigh`, highlight stroke `primary`. Typography Inter (fallback) + JetBrains Mono for source — per `ui-context.md:Typography`. No mesh/noise/gradient decoration. The demo proves the **tool's** aesthetic, not unrelated marketing fluff.
- Motion: implicit only (panel slide) + `disableAnimations` pass-through — same as L04/L05.
- ASCII diagrams above are the wireframe — bottom sheet narrow, side panel wide (≥900).

### Differentiation

- `Widgetation` demo is a component explorer; `Flan` demos a custom canvas. This demo is an **acceptance harness**: 5 types × nested × 2 routes × source-available + framework-source-null regions — exactly the `spec.md:Acceptance Test` checklist, not a marketing gallery.

### Testing & Analyze Notes

- Run `flutter analyze` in root + `cd example && flutter analyze` (both must be No issues).
- Run `flutter test` (root) + optional `flutter test` in example.
- Run `flutter build web` (always), plus spot builds for remaining 5 based on runner OS.
- Manual: all 6 builds succeed; on Web + one desktop, highlight aligns and panel updates correctly for 5 types.

### How to verify

```ps
flutter analyze                    # root — No issues
flutter test                       # root — existing level tests
cd example
flutter analyze                    # example — No issues
flutter test                       # if demo smoke test exists
flutter build web --no-pub        # proof it compiles
# manual: flutter run -d chrome
#   toggle Inspect ON -> tap Button -> Card -> Checkbox -> see panel update
```

