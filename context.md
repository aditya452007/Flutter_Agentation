# Flutter Agentation --- Project Context

## 1. Project Vision

Flutter Agentation is a developer-first visual inspection and, in later
versions, visual UI manipulation tool for Flutter applications.

The core idea is inspired by the workflow of tools such as Agentation
and VisBug:

> Let a developer point at something in a running UI, understand exactly
> what it is, describe what is wrong, and produce high-quality context
> that an external coding agent can use to modify the real source code.

This project is **not an AI coding agent**.

It does not contain an LLM, call an AI API, generate code autonomously,
or modify the user's source code itself.

The tool is a visual/context bridge between a Flutter application and an
external AI coding workflow.

## 2. Core Principle

The architecture should preserve this separation:

``` text
Flutter Application
        |
        v
Flutter Agentation
        |
        +--> Inspect UI
        +--> Identify widget
        +--> Resolve source location
        +--> Capture geometry/context
        +--> Add developer annotations
        |
        v
Structured UI Context
        |
        v
Developer copies context
        |
        v
External AI Coding Agent
Claude / Codex / Gemini / Cursor / etc.
        |
        v
Actual source-code modification
```

The external AI owns code modification.

Flutter Agentation owns visual understanding and context generation.

## 3. Target Platforms

The long-term scope is Flutter across platforms:

-   Android
-   iOS
-   Web
-   Windows
-   macOS
-   Linux

Version 1 should prioritize a robust inspection experience across the
supported Flutter targets rather than attempting every advanced feature
simultaneously.

## 4. Version Strategy

### Version 1 --- Inspect Mode

Version 1 is intentionally narrow.

Primary capabilities:

-   activate inspection mode
-   select/point at widgets
-   identify the selected widget
-   identify relevant widget hierarchy
-   retrieve source location where available
-   retrieve bounds and useful runtime properties
-   display selection overlays
-   add textual annotations/feedback
-   generate structured Markdown context
-   optionally include screenshots/visual evidence where technically
    appropriate
-   copy context to clipboard

Version 1 must NOT attempt to become a visual editor.

### Version 2 --- Design Mode

Version 2 introduces temporary visual manipulation.

The user should be able to experiment with the running UI without
changing the Dart source directly.

Potential capabilities:

-   move widgets
-   resize widgets
-   adjust spacing/padding
-   modify colors
-   modify typography
-   modify border radius/border
-   modify shadows
-   adjust alignment
-   reorder widgets
-   replace widgets
-   manipulate layouts
-   responsive viewport-specific experimentation
-   image replacement
-   masking
-   freehand drawing
-   arrows and visual annotations
-   undo/redo for the temporary visual session
-   generate a visual change diff/context package

The design system must treat these as temporary visual overrides until
the developer sends the resulting context to an external coding agent.

### Version 3 --- MCP

Version 3 introduces an MCP server.

The external AI agent can then inspect the running Flutter application
and retrieve structured information programmatically.

Possible capabilities:

-   get selected widget
-   get widget tree
-   get widget metadata
-   get source locations
-   get geometry
-   get annotations
-   get screenshots
-   get visual modifications
-   get the current UI context

The MCP server must remain agent-agnostic.

## 5. Important Product Constraint

Do not prematurely implement Version 2 or Version 3 while building
Version 1.

The codebase should be architected so that later versions are possible,
but Version 1 should remain focused.

Avoid speculative abstractions that add complexity without supporting
Version 1.

## 6. Existing Ecosystem

The project should study existing implementations before deciding
whether to build from scratch.

Important references include:

-   Widgetation
-   Flutter Pintap
-   Flan / flan_flutter
-   Flutter DevTools Inspector
-   Flutter WidgetInspector
-   Flutter Element tree
-   Flutter RenderObject tree
-   Flutter hit testing
-   Flutter source creation locations

The project should not blindly fork any existing project.

The engineering process must first understand:

1.  architecture
2.  source-location strategy
3.  widget-selection strategy
4.  rendering/overlay strategy
5.  platform limitations
6.  licensing
7.  extension points
8.  maintenance quality
9.  coupling to unrelated features

Only then should the team decide whether to: - reuse a dependency -
adapt selected implementation ideas - fork a project - or implement a
focused architecture independently.

## 7. Product Philosophy

The product should feel like a developer tool rather than an AI product.

It should be:

-   deterministic
-   lightweight
-   inspectable
-   agent-agnostic
-   local-first
-   privacy-conscious
-   compatible with normal Flutter development
-   useful without any AI subscription

The developer should always remain in control.

## 8. Git and History

Do not build a separate persistent design-history system merely for
undo/redo or long-term versioning.

Git already provides source history.

Temporary Version 2 manipulation history may exist in memory for
session-level undo/redo, but persistent historical state is not a
Version 1 requirement.
