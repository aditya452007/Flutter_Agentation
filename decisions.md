# Flutter Agentation --- Architecture Decision Record

## Decision 001 --- Build on Existing Knowledge, Not Blindly Fork

### Decision

Do not immediately fork Flan, Widgetation, or Pintap.

First inspect their repositories and implementation patterns.

After reconnaissance, choose between:

1.  independent implementation
2.  dependency reuse
3.  selective adaptation
4.  fork

### Reason

The existing projects are valuable because they have already solved
difficult Flutter runtime problems.

However, their product goals may differ from Flutter Agentation.

A direct fork can create unwanted coupling and technical debt.

### Rule

Reuse proven mechanisms where they fit, but keep ownership of the
product architecture.

------------------------------------------------------------------------

## Decision 002 --- No Built-in AI

### Decision

Flutter Agentation contains no AI model and does not call AI APIs.

### Reason

The product is intended to be agent-agnostic and useful independently of
any particular AI provider.

### Consequence

The primary output is structured context, not generated code.

------------------------------------------------------------------------

## Decision 003 --- External Agent Workflow

The intended workflow is:

``` text
Inspect UI
    ↓
Annotate / describe issue
    ↓
Generate context
    ↓
Copy Markdown
    ↓
External coding agent
    ↓
Agent modifies source
    ↓
Developer reviews changes
```

Later, MCP can make the context retrievable programmatically.

------------------------------------------------------------------------

## Decision 004 --- Versioned Feature Expansion

### V1

Inspect mode only.

### V2

Design mode with temporary visual manipulation.

### V3

MCP server.

Do not collapse all three versions into the first implementation.

------------------------------------------------------------------------

## Decision 005 --- Temporary Visual Editing

Version 2 manipulations should not directly mutate Dart source.

Instead:

``` text
Original runtime UI
       ↓
Temporary override layer
       ↓
Modified visual result
```

The final desired state is exported as structured context.

------------------------------------------------------------------------

## Decision 006 --- Capture Both Facts and Intent

When a developer moves or changes a widget, the system should preserve
factual changes where possible.

Example:

``` text
Observed:
x: +40 px

Desired:
move button toward right edge
```

The tool should not pretend to understand semantic intent if it cannot
reliably infer it.

It should preserve measurable facts and developer-provided intent
separately.

------------------------------------------------------------------------

## Decision 007 --- Responsive Editing

Version 2 should support viewport-aware experimentation.

A manipulation should be associated with the active viewport/device
configuration where possible.

Avoid assuming that a change at one width automatically means a
universal responsive rule.

------------------------------------------------------------------------

## Decision 008 --- History

Do not create a persistent application-specific source history system.

Use Git for source history.

Temporary design-session undo/redo is acceptable in Version 2.

------------------------------------------------------------------------

## Decision 009 --- MCP

MCP is Version 3.

The MCP layer must expose structured inspection/context capabilities
without coupling the core package to a particular AI vendor.

------------------------------------------------------------------------

## Decision 010 --- Markdown First

Markdown is the primary human-readable export format.

A machine-readable representation such as JSON may exist internally or
alongside Markdown, but Version 1 should prioritize a clean,
understandable Markdown artifact.

------------------------------------------------------------------------

## Decision 011 --- Developer Approval

Flutter Agentation never silently modifies source code.

The external coding agent may propose or perform source modifications
according to the developer's workflow, but Flutter Agentation itself is
an inspection/context tool.

------------------------------------------------------------------------

## Decision 012 --- Scope Discipline

Do not implement speculative features simply because they may be useful
in Version 2 or Version 3.

Every Version 1 feature must directly support:

> selecting a UI element and producing high-quality actionable context.
