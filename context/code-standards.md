# Code Standards — Flutter Agentation (Dart/Flutter)

## General

- Keep widgets and classes small and single-purpose — **max ~300 lines per file**, **max ~80 lines per `build` method** — extract sub-widgets.
- Fix root causes — do not layer workarounds.
- Separation is the rule: runtime inspection vs presentation, facts vs intent vs visual, host app vs overlay (`build-instructions.md:140-151`).
- Every feature must directly support `selection → context → Markdown`; no speculative V2/V3 behavior (`decisions.md:D-012`).
- Never use `flutter pub add` with `dependency_overrides` to silence conflicts — resolve version constraints properly.
- Minimal dependencies: "Do not introduce a large external dependency merely because it already implements part of the feature" (`build-instructions.md:06`).

## Dart — Strict & Safe

- **Lint**: `analysis_options.yaml` with `package:flutter_lints/flutter.yaml` or `package:very_good_analysis/very_good_analysis.yaml`. **Zero `info`/`warning` on CI**; format before each commit (`build-instructions.md:181-188`).
- **No `dynamic` at boundaries** — validate via `freezed`/`json_serializable` or sealed classes; debug/source strings are `String?`.
- **Null safety throughout** — no `!` without a preceding check/`assert`; use `?` + early return; missing source/bounds is `T?`, not a throw.
- Prefer `final` over `var`; `const` constructors wherever possible (`prefer_const_constructors`).
- Naming: `lowerCamelCase` for vars/functions, `UpperCamelCase` for types. File names `snake_case.dart`.

## Flutter Framework — Inspector Rules

- Prefer **stateless + notifiers** for the overlay (e.g., `ValueNotifier<bool> selected`) — avoid pulling in a state-management framework unless a seam truly needs it (`build-instructions.md:155`).
- **Reuse Flutter's inspection infra** — `Element`, `Widget`, `RenderObject`, `RenderBox.hitTest`/`BoxHitTestResult`, `WidgetInspector` — do not reimplement hit-testing (`architecture.md:87-93`, `decisions.md:D-001`).
- Overlay is **non-destructive**: when disabled, host app behavior is identical to not wrapping with `AgenationOverlay` — no global `Builder` darts, no permanent `Listener` that swallows gestures.
- Source location is `SourceLocation?` — UI and exporter both handle `null` via an `UnavailableLabel` / "Source unavailable" branch (`spec.md:FR-005`, `architecture.md:40-55`).
- Handle all panel states: loading/resolving, resolved, source unavailable, no selection, copy success/failure, screenshot unavailable — map to `States.md` where applicable.

## Project Layout — Package, Not a Studio App

Agenation is a **package** consumed by a host app, with an `example/` demo:

```
lib/
├── agentation.dart             # public barrel — only this is the package API
├── src/
│   ├── overlay/                # AgentationOverlay, highlight, panel
│   ├── selection/              # SelectionEngine (hit-testing, adapters)
│   ├── resolver/               # WidgetResolver, SourceResolver, BoundsExtractor, HierarchyExtractor
│   ├── context/                # ContextModel (facts/intent/visual stub), ContextCollector
│   ├── annotation/             # AnnotationManager, DeveloperNote
│   ├── exporter/               # MarkdownExporter, JsonExporter, Clipboard
│   └── core/                   # interfaces, platform adapters, SourceLocation, Rect helpers
example/
├── lib/main.dart               # minimal demo app (multiple widget types + nested — acceptance requires it)
test/
├── resolver_test.dart          # source available / unavailable, bounds, hierarchy
├── context_collector_test.dart
├── exporter_test.dart          # Markdown stability snapshots
└── overlay_golden_test.dart
```

- **Public API via `lib/agentation.dart` only** — consumers never import `lib/src/*`. Every internal module is private.
- **No flat `lib/components/` or `lib/utils/`** — group by pipeline stage (`lib/src/resolver/`, etc.).
- **No cross-pipeline imports that skip the model** — resolver/coller do not directly call exporter; collector produces the model, exporter consumes it — one direction (`architecture.md:83-311`).

## Exporter Stability

- `MarkdownExporter.export(ContextModel)` is a **pure, deterministic function** — same model always produces byte-identical Markdown (tested via snapshots). Field order, line breaks, and section headings must not drift (`architecture.md:196-198`).
- Sections: `Target / Source / Geometry / Hierarchy / Runtime Details / Developer Feedback / Visual Evidence` — follow `spec.md:134-175` but adapt after reconnaissance if Flutter APIs constrain fields.
- JSON is a straight serialization of the same model for future MCP — never a second inspection path.

## Styling (Overlay UI)

- No hardcoded colors/spacing — all via `ThemeData`, `ColorScheme`, `ThemeExtension` + spacing constants in `lib/src/core/spacing.dart` or `Gap`.
- Overlay tokens centralized in `lib/src/overlay/tokens.dart`.

## Animation

- Prefer implicit animations (`AnimatedContainer`/`Opacity`/`Switcher`/`Positioned`) and `flutter_animate` only if a list/stagger is needed.
- Never animate layout properties via `setState` loops — use `AnimationController` + `Transform`/`Opacity`.
- Durations micro 150 / standard 250 / entrance 300; `Curves.easeOutCubic`; respect `MediaQuery.disableAnimations`.

## Testing

- **Unit**: widget resolution (available/unavailable source), bounds (including zero-size), hierarchy bounds capping, annotation, exporter stability, JSON round-trip — `architecture.md:31-40`.
- **Widget/golden**: overlay highlight alignment at various device sizes; golden for panel layout.
- **Integration**: via `example/` — representative app (multiple types + nesting), not only synthetic units.
- Minimum for V1 acceptance (`spec.md:Acceptance Test`): selecting multiple widget types + nested + source when available + bounds + hierarchy + feedback + Markdown + copy + graceful unavailable.

## Pre-Commit Checks (every work unit) — `build-instructions.md:Git Workflow`

1. `dart format .`
2. `flutter analyze` — zero issues
3. `flutter test` — all relevant tests pass (include exporter snapshot)
4. Inspect `git diff` — no `build/`, `.dart_tool/`, `*.freezed.dart`/`*.g.dart` surprises, no secrets
5. `context/progress-tracker.md` updated
6. No hardcoded colors — all via Theme/ColorScheme
7. No speculative V2/V3 code beyond declared seams
8. Fork-vs-build assessment stays current if any reused code is introduced

## Prohibited Practices

- No AI/LLM SDK, no MCP server, no network calls, no Dart source mutation in V1 (`spec.md:FR-012/013`, `decisions.md:D-002`).
- No full design-mode UI (move/resize/color editor) in V1 (`design-statement.md:116-120`).
- No persistent design-history system — use Git; only in-memory undo/redo stub for V2 seam if any (`decisions.md:D-008`).
- No copying large portions of Flan/Pintap/Flan_flutter/DevTools without a documented reason (`build-instructions.md:Code Quality`).
- No `import 'package:agentation/src/...'` from consumers — barrel only.
