# Architecture Context — Flutter Agentation

## Architectural Goal

Build a **modular Flutter developer tool** that inspects a running Flutter app's UI and converts runtime UI information into structured developer feedback. Must leave **clean extension points for V2 (visual manipulation) and V3 (MCP)** without implementing them prematurely. See `architecture.md:1-14`, `decisions.md:Decision 004`.

## Stack

| Layer | Technology | Role | Notes |
|-------|-----------|------|-------|
| Framework | **Flutter 3.x + Dart 3.x** (null safety) | Host + target inspection | Long-term: Android/iOS/Web/Windows/macOS/Linux (`context.md:59-70`) |
| Language | Dart | All tool + demo code | Idiomatic, small focused classes, immutable models where practical (`build-instructions.md:140-151`) |
| Inspection | Flutter framework APIs | **Single source of truth** | `Element` tree, `Widget`, `RenderObject`, hit-testing (`HitTestResult`, `RenderBox`), `WidgetInspector`/`DevTools` facilities — **reuse, do not duplicate** (`architecture.md:87-93`) |
| Source Location | Flutter debug inspection | File:line:column | Optional — unavailable in release/generated/framework widgets; UI must say "unavailable", not fabricate (`architecture.md:39-55`, `spec.md:FR-005`) |
| State (tool UI) | Minimal — `ValueNotifier` / `ChangeNotifier` or `Riverpod` if justified | Overlay + selection + annotations | Avoid unnecessary state-management framework (`build-instructions.md:155`) |
| Clipboard/Screenshots | `clipboard` + screenshot service (optional) | Copy Markdown / visual evidence | Screenshot subsystem must not block inspection if unavailable (`spec.md:FR-009`) |
| Markdown/JSON | Pure Dart exporter | Deterministic output for agents/MCP | `architecture.md:38`, `decisions.md:Decision 010` |
| Testing | `flutter_test` + `integration_test` + goldens | Selection/hierarchy/bounds/serialization/Markdown stability | `architecture.md:31-40` |
| Lint | `flutter_lints` / `very_good_analysis` | Zero analyzer issues | `build-instructions.md:183-188` |

No AI SDK, no LLM call, no MCP server in V1 — explicitly deferred (`build-instructions.md:106-124`, `decisions.md:Decision 002/009`).

## High-Level Architecture

```text
+------------------------------------------------------+
|                 Flutter Application                  |
|                                                      |
|  +-----------------------------------------------+   |
|  |          Agentation Overlay / UI              |   |
|  +----------------------+------------------------+   |
|                         |                            |
|  +----------------------v------------------------+   |
|  |              Selection Engine                 |   |
|  | hit testing / pointer coordinates / selection  |   |
|  +----------------------+------------------------+   |
|                         |                            |
|  +----------------------v------------------------+   |
|  |              Widget Resolver                  |   |
|  | Element / Widget / RenderObject information   |   |
|  +----------------------+------------------------+   |
|                         |                            |
|  +----------------------v------------------------+   |
|  |             Context Collector                |   |
|  | source / tree / bounds / properties / notes   |   |
|  +----------------------+------------------------+   |
|                         |                            |
|  +----------------------v------------------------+   |
|  |             Annotation Manager                |   |
|  | point/selection + textual note (V1)          |   |
|  +----------------------+------------------------+   |
|                         |                            |
|  +----------------------v------------------------+   |
|  |              Context Exporter                 |   |
|  |              Markdown / JSON                  |   |
|  +------------------------------------------------+   |
+------------------------------------------------------+

Version 3:
                    Context / Inspector API
                              |
                              v
                         MCP Server
                              |
                              v
                     External AI Agent
```

Version correctness — one model, two adapters (`architecture.md:83-311`):

```text
             Context Model (single source of truth)
             /           \
            /             \
       Markdown           MCP
       exporter          adapter
```

Not two inspection implementations.

## Core Modules (V1 scope)

### 1. Overlay (`architecture.md:3.1`)
- Activate/deactivate inspection mode
- Selection visuals: border/bounds indicator, hover target where supported
- Annotation affordance + Copy button
- Non-destructive: when disabled, app behavior is untouched
- Golden tests for rendering

### 2. Selection Engine (`architecture.md:3.2`)
Input: pointer/touch coordinate, render tree, platform/runtime
Output: selected `Element`/`Widget`, relevant `RenderObject`, bounds (`Rect`/`Size`), hierarchy slice
- Must leverage Flutter's hit-testing (`RenderBox.hitTest`, `BoxHitTestResult`) and inspector infra, not reimplement

### 3. Widget Resolver (`architecture.md:3.3`)
Possible fields — explicitly **optional** (`Value?`) because availability varies:

```text
widgetType, runtimeType, sourceFile, sourceLine, sourceColumn,
key, bounds, size, parent, ancestors, children, text, semantics, properties
```

Source location is **optional**, not required — treat as `sourceLocation = available ? location : null`.

### 4. Context Collector (`architecture.md:3.4`)
Combines into a **normalized internal model** with strict separation (`architecture.md:4`):

- **Runtime facts** (observed): widget type, bounds, source, hierarchy, text, key
- **Developer intent** (authored): annotation text — e.g., "This button should align with card edge"
- **Visual changes** (V2 only): `width: 120→160, x: +40` — **not in V1**

Separation prevents presenting guesses as facts.

### 5. Annotation Manager (`architecture.md:3.5`)
V1: `point/selection + textual note + selection metadata`
V2 extension points (deferred but seam must exist): rectangle, arrow, freehand, mask, image replacement, visual diff. V1 must not require the V2 drawing engine.

### 6. Context Exporter (`architecture.md:3.6`, `spec.md:Suggested Context Output`)
Deterministic Markdown (primary, `decisions.md:Decision 010`) + optional JSON (same model). Stable enough for agents.

```markdown
# Flutter UI Feedback

## Selected Widget
## Source
## Geometry
## Hierarchy
## Runtime Details
## Developer Feedback
## Visual Evidence
```

## Source Location & Platform Rules

- Obtain via Flutter-supported debug/inspection facilities (`architecture.md:39-55`); treat as `Optional<SourceLocation>`.
- Production/release, generated, and framework widgets may lack locations — UI shows "Source unavailable in this build" (`spec.md:FR-005`).
- Core inspection model stays **platform-neutral**; isolate platform quirks behind interfaces/adapters only when the runtime requires it — do not duplicate business logic per OS (`architecture.md:56-65`).

## Version 2 & 3 Boundaries (do not build, but do not block)

- **V2 visual override** (`architecture.md:67-82`, `decisions.md:Decision 005/006/007`): `Selection → Visual Override → Override State (serializable) → Overlay/Rendering`. Overrides are **temporary**, serialized as change descriptions (`x: 100→140`) + separate `developer intent` — Git remains history (`decisions.md:Decision 008`). Responsive: associate manipulation with active viewport (`Decision 007`).
- **V3 MCP** (`architecture.md:83-311`, `decisions.md:Decision 009`): expose existing context APIs via MCP server; agent tools: get selected widget / tree / metadata / source / geometry / annotations / screenshots / full context. Must remain **agent-agnostic**.

## Project Layout (canonical — materialize after reconnaissance)

Per `folder-structure` mobile tree + `build-instructions.md:Git Workflow`:

```
lib/
├── src/
│   ├── overlay/            # AgentationOverlay, activation, selection visuals
│   ├── selection/          # SelectionEngine, hit-testing adapters
│   ├── resolver/           # WidgetResolver, SourceResolver, BoundsExtractor
│   ├── context/            # ContextModel (facts/intent/visual — V2 stub), ContextCollector
│   ├── annotation/         # AnnotationManager, AnnotationModel
│   ├── exporter/           # MarkdownExporter, JsonExporter, Clipboard
│   └── core/               # platform adapters, interfaces, types
├── agentation.dart         # public barrel
example/
├── lib/main.dart           # minimal demo app (required for acceptance)
test/
├── context_collector_test.dart
├── exporter_test.dart
├── widget_resolver_test.dart
└── overlay_golden_test.dart
```

Alternative if published as a package: `packages/agnetation/` with `example/` sibling — decision after reconnaissance (`build-instructions.md:Mandatory First Phase`).

## Invariants

1. `flutter analyze` zero issues on every commit.
2. V1 has **no network, no AI, no MCP, no visual manipulation** — those are V2/V3 seams only.
3. Source location is optional — never fabricate.
4. Overlay disabled ⇒ app behavior identical to not having the package.
5. One normalized ContextModel is the single source of truth for Markdown and future MCP.
6. Facts vs intent vs visual diff are separate fields — never conflate.
7. Features degrade gracefully: missing bounds/source/screenshot never crashes selection.
8. Small focused classes; minimal dependencies; reuse Flutter's inspection infra.

## Testing & Security

- Unit: context models, `WidgetResolver` (available/unavailable source), bounds, hierarchy, annotation, Markdown stability (`architecture.md:31-40`).
- Widget/integration: selection with nested trees; golden overlays.
- Integration via representative demo app, not only synthetic units.
- Security: **local-only by default**, no source upload because tool is installed, V1 has no network (`architecture.md:32-35`, `spec.md:FR-012`).
