# Feature Docs — Flutter Agentation V1 (Inspect Mode)

This directory contains **level-by-level, small, independently testable specs** for V1. Only specs are written in this phase — no Dart production code beyond the toolchain already scaffolded (`pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `.specify/`).

Implementation will proceed **one level at a time**, each gated by `flutter analyze` + `flutter test` (when code exists) and **Spec → Clarify → Approve → Implement**.

| Level | Folder | Feature | V1 Scope | Depends on |
|-------|--------|---------|----------|------------|
| **L00** | `L00-foundation/` | Foundation & Toolchain | pubspec + lint + gitignore + Specify | — |
| **L01** | `L01-core-models/` | Core Context Models | ContextModel (facts/intent/visual stub) | L00 |
| **L02** | `L02-widget-resolver/` | Widget Resolver | widgetType, source?, bounds, hierarchy | L01 |
| **L03** | `L03-selection-engine/` | Selection Engine | hit-testing, selected Element/Rect | L02 |
| **L04** | `L04-overlay-activation/` | Overlay & Activation | AgentationOverlay, enable toggle, highlight | L03 |
| **L05** | `L05-info-panel/` | Info Panel | widget/source/geometry/hierarchy UI | L04 |
| **L06** | `L06-annotation/` | Annotation System | Developer note + AnnotationManager | L05 |
| **L07** | `L07-exporter-clipboard/` | Exporter & Clipboard | Markdown/JSON deterministic + copy | L06 |
| **L08** | `L08-demo-app/` | Minimal Demo App | 2-3 screen demo to validate selection | L07 |

**Stack for all specs**: Flutter **3.44.9** stable + Dart **3.12.2** (latest at spec time, see `flutter --version`), `very_good_analysis` 7.x, `flutter_test`. No AI/MCP/visual-edit deps in V1.

**Spec template**: each `spec.md` follows `/.specify/templates/spec-template.md` (User Scenarios, Requirements, Entities, Success Criteria, Assumptions) **plus** Flutter-specific sections added per your request: Languages, Folder Structure, Files to Create, Classes, Functions, ASCII Diagrams, Design (instrument, not AI slop), Differentiation from existing tools, Testing & Analyze notes.

**How to use Specify**: run `specify init` already done → then for each level run `/speckit.specify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.implement` per level. Current phase = specs only — plans/tasks/implement come after your approval.

All generated files (`*.freezed.dart`, `*.g.dart`, `.dart_tool/`, `build/`) are ignored via `.gitignore:11-16` and `analysis_options.yaml:analyzer.exclude:2-8` so `flutter analyze` stays green.

