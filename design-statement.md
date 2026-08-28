# Flutter Agentation --- Design Statement

## Design Philosophy

Flutter Agentation should feel like a precise developer instrument
rather than an AI application.

The visual language should communicate:

-   inspection
-   precision
-   hierarchy
-   control
-   low cognitive load

Avoid excessive decoration.

## Core Interaction

The primary interaction is:

``` text
Inspect → Select → Understand → Annotate → Export
```

The tool should make the selected UI element visually obvious without
obscuring the application.

## V1 Interface

The minimum interface should contain:

### Inspection control

A compact control for activating inspection.

### Selection indicator

A clear boundary around the selected widget.

### Information panel

Displays:

-   widget type
-   source
-   bounds
-   hierarchy
-   useful properties

### Feedback field

A simple text input for the developer's note.

### Copy Context

A prominent action that copies the generated Markdown.

## V2 Visual Editing Direction

Version 2 should introduce a design-mode interaction inspired by
direct-manipulation browser tools.

Potential controls:

-   move
-   resize
-   spacing
-   alignment
-   color
-   typography
-   borders
-   shadows
-   reorder
-   replace
-   layout
-   image manipulation
-   drawing
-   masking

The developer should see the modified visual result immediately.

The modifications are temporary until external code changes are made.

## Visual Evidence

Version 2 should make it possible to communicate visual intent through:

-   rectangles
-   arrows
-   freehand marks
-   masks
-   replacement assets
-   before/after state

The exported context should contain both machine-readable facts and
human-readable intent.

## Important Principle

The tool should not attempt to infer semantic design intent when the
only available information is a geometric manipulation.

For example:

``` text
Observed:
x changed from 100 to 140

Developer intent:
"Align this with the right edge."
```

Both should be preserved.

## V1 Design Restraint

Do not implement the complete design-mode UI in V1.

The V1 interface should be optimized for inspection and context
generation.
