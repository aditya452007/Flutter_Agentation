# Flutter Agentation --- Problem Statement

## Problem

Modern AI coding agents can modify Flutter source code effectively, but
developers still have a communication problem when the requested change
is visual.

A developer sees a running application and thinks:

> "This button is too low."

or:

> "This spacing feels wrong."

or:

> "Move this card slightly to the right."

The developer then has to manually explain:

-   which widget
-   which screen
-   which source file
-   which part of the widget tree
-   what the current visual state is
-   what should change

This creates friction between visual perception and source-code
modification.

## Existing Web Pattern

Browser-oriented tools can inspect rendered HTML/DOM elements and
associate them with source context.

Flutter does not expose an HTML DOM because Flutter uses its own widget,
element, and render-object model.

However, Flutter's inspection/debugging infrastructure provides enough
runtime information to build an equivalent developer workflow.

## Proposed Solution

Flutter Agentation provides a visual inspection layer for Flutter.

The developer can select a UI element and receive structured context
such as:

``` text
Widget:
ElevatedButton

Source:
lib/screens/home.dart:143

Bounds:
x=32, y=540, width=320, height=52

Hierarchy:
Scaffold
└── Column
    └── Card
        └── ElevatedButton

Feedback:
"Make this button more rounded."
```

This context can be copied into an external AI coding agent.

## Version 1 Problem

Solve only:

> How can a Flutter developer visually identify a widget and communicate
> precise, source-aware feedback to an external coding agent?

## Version 2 Problem

Expand the system so that developers can visually demonstrate desired
changes rather than merely describing them.

Examples:

-   move a widget
-   resize it
-   change spacing
-   change color
-   change typography
-   reorder elements
-   replace widgets
-   manipulate layout
-   draw annotations
-   replace/mask assets

The result remains a temporary visual state, not source-code mutation.

## Version 3 Problem

Allow external AI agents to retrieve the same runtime UI context
programmatically through MCP.

## Non-Goals

The project does not initially aim to:

-   build an AI model
-   provide an AI chat assistant
-   modify source code automatically
-   replace Git
-   replace Flutter DevTools
-   become a full IDE in Version 1
-   support every advanced visual editing operation immediately

## Success Criterion for V1

A developer should be able to:

1.  run a Flutter application
2.  activate Agentation
3.  select a widget
4.  see useful widget/source information
5.  add a clear note
6.  copy a structured Markdown context
7.  paste that context into an external coding agent
8.  have enough information for the agent to understand the requested UI
    change without manually rediscovering the target widget.
