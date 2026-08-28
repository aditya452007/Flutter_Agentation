# Flutter Agentation --- Build Instructions for the Coding Agent

## Mission

Build Version 1 of Flutter Agentation: a Flutter-native visual
inspection and context-generation tool.

Do not implement Version 2 or Version 3 yet.

## Mandatory First Phase --- Reconnaissance

Before writing production code:

1.  inspect the entire repository
2.  understand the existing project structure
3.  identify package boundaries
4.  identify Flutter/Dart versions
5.  identify current dependencies
6.  inspect existing tests
7.  inspect README/documentation
8.  inspect build scripts
9.  inspect linting/formatting configuration
10. identify whether the repository already contains any inspector,
    overlay, debugging, or MCP infrastructure

Then study the relevant existing projects/approaches:

-   Widgetation
-   Flutter Pintap
-   Flan / flan_flutter
-   Flutter DevTools Inspector
-   Flutter WidgetInspector
-   Flutter Element APIs
-   Flutter RenderObject APIs
-   hit testing APIs

Do not immediately fork anything.

## Fork-vs-Build Decision

Create a short engineering assessment after reconnaissance.

Compare:

-   source-selection mechanism
-   source-location mechanism
-   widget hierarchy extraction
-   bounds extraction
-   overlay implementation
-   annotation architecture
-   platform support
-   dependency footprint
-   code quality
-   license
-   maintenance activity
-   extension points
-   coupling to AI/MCP systems

Then decide whether to:

-   reuse
-   depend on
-   adapt
-   fork
-   or implement independently.

Record the decision in the project documentation.

Do not introduce a large external dependency merely because it already
implements part of the feature.

## Required Project Documentation

Create/update a `/context` or equivalent documentation directory
containing:

-   context.md
-   decisions.md
-   architecture.md
-   problem-statement.md
-   spec.md
-   design-statement.md
-   build-instructions.md

Keep these documents synchronized with actual implementation decisions.

## Version 1 Scope

Implement:

-   inspection activation
-   widget selection
-   selection overlay
-   widget identification
-   source location where available
-   bounds
-   hierarchy
-   useful runtime metadata
-   textual annotations
-   Markdown generation
-   clipboard copy
-   graceful handling of unavailable metadata
-   tests
-   minimal demo/example application

## Explicitly Do Not Implement

Do not implement:

-   built-in AI
-   AI API calls
-   LLM integration
-   automatic source-code modification
-   MCP server
-   visual manipulation
-   drag-to-move
-   resize handles
-   color editing
-   typography editing
-   widget replacement
-   visual layout editor
-   persistent design history
-   unnecessary backend services

These belong to later versions.

## Architecture Requirement

Build around a reusable normalized context model.

The core inspector should produce structured context once.

Markdown export should consume that model.

Future MCP should consume the same model.

Future design mode should extend the model rather than replace it.

## Code Quality

Use idiomatic Dart and Flutter.

Prefer:

-   small focused classes
-   explicit interfaces
-   immutable data models where practical
-   clear separation between runtime inspection and presentation
-   unit tests for context models and exporters
-   widget/integration tests for selection behavior
-   minimal dependencies

Avoid:

-   speculative abstractions
-   giant service classes
-   unnecessary state-management frameworks
-   hard-coded application-specific assumptions
-   copying large portions of external projects without a documented
    reason

## Git Workflow

Work in small logical commits.

Suggested sequence:

1.  repository reconnaissance and documentation
2.  core context models
3.  widget/source resolver
4.  selection engine
5.  overlay
6.  annotation system
7.  Markdown exporter
8.  clipboard integration
9.  demo application
10. tests and hardening

Each commit should represent one coherent change.

Do not create meaningless commits such as "changes" or "updates".

Before each commit:

-   format code
-   run analyzer/linter
-   run relevant tests
-   inspect the diff
-   verify no generated or secret files were accidentally included

## Completion Criteria

V1 is complete only when a developer can run the demo, select a widget,
inspect meaningful runtime/source context, write feedback, and copy a
useful Markdown artifact for an external AI coding agent.

Do not claim completion if the workflow only works for one hard-coded
demo widget.

## Development Discipline

If a technical requirement is uncertain, investigate the actual Flutter
API/repository before guessing.

If an existing project appears useful, inspect its implementation rather
than assuming how it works.

If a feature belongs to V2 or V3, document the extension point and defer
implementation.

The goal is not maximum feature count.

The goal is a clean, battle-tested foundation for the later visual
design and MCP layers.
