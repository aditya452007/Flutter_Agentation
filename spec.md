# Flutter Agentation --- Version 1 Specification

## Product Name

Flutter Agentation

## Version

V1 --- Inspect Mode

## Primary User

Flutter developer using an external AI coding agent.

## Core User Journey

``` text
Start Flutter app
      ↓
Activate Agentation
      ↓
Select widget
      ↓
Inspect widget
      ↓
Add feedback
      ↓
Generate context
      ↓
Copy Markdown
      ↓
Paste into external coding agent
```

## Functional Requirements

### FR-001 --- Activation

The developer must be able to activate and deactivate inspection mode.

### FR-002 --- Widget Selection

The developer must be able to identify/select a widget from the running
UI.

### FR-003 --- Selection Overlay

The selected widget should have a visible overlay/bounds indicator.

### FR-004 --- Widget Identity

The tool should display useful identity information including widget
type/runtime type where available.

### FR-005 --- Source Location

The tool should display source file, line, and column when Flutter's
runtime/debug information makes them available.

If unavailable, the UI should say so rather than fabricate information.

### FR-006 --- Geometry

The tool should provide useful bounds/size information.

### FR-007 --- Hierarchy

The tool should provide meaningful ancestor/parent/child context.

The hierarchy should be bounded to avoid generating unnecessarily huge
outputs.

### FR-008 --- Developer Feedback

The developer must be able to attach a textual note to the selected
target.

### FR-009 --- Screenshot Evidence

Where technically supported, the context may include a screenshot or
reference to captured visual evidence.

The screenshot subsystem must not block basic inspection if capture is
unavailable.

### FR-010 --- Context Generation

The tool must generate a deterministic Markdown representation of the
selected UI context.

### FR-011 --- Copy

The developer must be able to copy the generated Markdown.

### FR-012 --- No Network Dependency

V1 must not require an external server or AI API.

### FR-013 --- No Source Mutation

V1 must not modify the developer's Dart source code.

### FR-014 --- Debug-Oriented Operation

The implementation should be designed primarily for development/debug
workflows.

## Non-Functional Requirements

### Performance

Inspection should add minimal overhead to normal development.

### Reliability

Selection should work with deeply nested widget trees.

### Extensibility

Internal APIs should permit Version 2 visual overrides and Version 3 MCP
without rewriting the core inspector.

### Maintainability

Prefer small modules with clear responsibilities over one monolithic
Agentation widget.

### Compatibility

Avoid unnecessary assumptions about a particular Flutter application
architecture.

## Suggested Context Output

``` markdown
# Flutter UI Feedback

## Target

- Widget: ElevatedButton
- Runtime Type: ElevatedButton

## Source

- File: lib/screens/home.dart
- Line: 143
- Column: 12

## Geometry

- X: 32
- Y: 540
- Width: 320
- Height: 52

## Hierarchy

Scaffold
└── Column
    └── Card
        └── ElevatedButton

## Runtime Details

- Text: Get Started
- Key: ...

## Developer Feedback

> Make this button more rounded and slightly taller.

## Visual Evidence

Captured screenshot available.
```

The exact fields should be adapted after repository reconnaissance and
Flutter API constraints are understood.

## Acceptance Test

A minimal demo application must demonstrate:

-   selecting multiple different widget types
-   selecting nested widgets
-   displaying source information when available
-   displaying bounds
-   displaying hierarchy
-   adding feedback
-   generating Markdown
-   copying Markdown

The implementation should also demonstrate graceful behavior when source
information is unavailable.
