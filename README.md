# Flutter Agentation --- Project Context Bundle

This folder contains the planning and engineering context for the
Flutter Agentation project.

Read these documents before implementing code:

1.  `context.md` --- overall product context and version strategy
2.  `decisions.md` --- architectural/product decisions made so far
3.  `architecture.md` --- proposed technical architecture
4.  `problem-statement.md` --- problem definition and non-goals
5.  `spec.md` --- Version 1 functional specification
6.  `design-statement.md` --- UX/design direction
7.  `build-instructions.md` --- instructions for the coding agent

The intended sequence is:

``` text
Read context
    ↓
Inspect repository
    ↓
Study existing Flutter tools
    ↓
Decide fork/reuse/build
    ↓
Document architecture decision
    ↓
Implement V1 Inspect Mode
```

Version boundaries:

-   V1: Inspect Mode
-   V2: Design Mode / temporary visual manipulation
-   V3: MCP server

The external AI coding agent is intentionally outside the Flutter
Agentation product.
