# Flutter Agentation --- Technical Architecture

## 1. Architectural Goal

Build a modular Flutter developer tool that can inspect a running
Flutter application's UI and convert runtime UI information into
structured developer feedback.

The architecture must leave clean extension points for:

-   Version 2 visual manipulation
-   Version 3 MCP

without implementing those systems prematurely.

## 2. High-Level Architecture

``` text
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

## 3. Core Modules

### 3.1 Overlay

Responsible for:

-   inspection activation
-   selection visuals
-   hover/target indication where supported
-   annotation UI
-   non-destructive UI chrome

The overlay must not interfere with the application when inspection mode
is disabled.

### 3.2 Selection Engine

Input:

-   pointer/touch coordinate
-   current render tree
-   active platform/runtime

Output:

-   selected Element/Widget
-   relevant RenderObject
-   bounds
-   hierarchy context

The implementation should leverage Flutter's existing inspection and
hit-testing mechanisms instead of duplicating the framework's behavior.

### 3.3 Widget Resolver

Responsible for turning a runtime selection into structured information.

Possible fields:

``` text
widgetType
runtimeType
sourceFile
sourceLine
sourceColumn
key
bounds
size
parent
ancestors
children
text
semantics
properties
```

Not every field is guaranteed for every widget/platform/build mode.

The context model must explicitly allow unavailable values.

### 3.4 Context Collector

Combines:

``` text
selected widget
+
hierarchy
+
source location
+
geometry
+
useful runtime properties
+
developer notes
+
annotations
+
screenshot metadata
```

into a normalized internal model.

### 3.5 Annotation Manager

Version 1:

-   point/selection
-   textual note
-   selection metadata

Version 2 extension points:

-   rectangle
-   arrow
-   freehand drawing
-   mask
-   image replacement
-   visual diff

The Version 1 implementation should not require the Version 2 drawing
engine.

### 3.6 Context Exporter

Primary output:

``` markdown
# Flutter UI Feedback

## Selected Widget

...

## Source

...

## Geometry

...

## Hierarchy

...

## Developer Feedback

...

## Visual Evidence

...
```

The exporter should be deterministic and stable enough to be consumed by
external coding agents.

## 4. Context Model

A normalized internal context model should distinguish:

### Runtime facts

Facts observed from the running application.

Examples:

-   widget type
-   bounds
-   source location
-   hierarchy
-   text
-   key

### Developer intent

What the developer says.

Example:

> "This button should align with the card edge."

### Visual changes

Version 2 only.

Examples:

``` text
width: 120 → 160
x: +40
radius: 8 → 16
```

This separation prevents the tool from presenting guesses as facts.

## 5. Source Location

Source locations should be obtained through Flutter-supported
debugging/inspection facilities wherever possible.

Source mapping must be treated as optional:

``` text
sourceLocation = available
```

rather than a hard requirement.

Production/release builds, generated widgets, framework widgets, and
certain runtime situations may not expose the same information.

## 6. Platform Architecture

The core inspection model should remain platform-neutral.

Platform-specific behavior should be isolated behind
interfaces/adapters.

Do not create separate business logic for Android, iOS, Web, Windows,
macOS, and Linux unless the underlying Flutter runtime requires it.

## 7. Version 2 Extension Boundary

Version 2 should introduce a separate visual override subsystem:

``` text
Selection
   ↓
Visual Override
   ↓
Override State
   ↓
Overlay / Rendering
```

It should not rewrite source code.

The override state should be serializable into a change description.

## 8. Version 3 Extension Boundary

Version 3 should expose existing context models through an MCP server.

The MCP layer should consume the same internal context APIs rather than
creating a second inspection implementation.

This is important:

``` text
             Context Model
             /           \
            /             \
       Markdown           MCP
       exporter          adapter
```

not:

``` text
Flutter Inspector
      ↓
Markdown system

Flutter Inspector 2
      ↓
MCP system
```

There should be one source of truth.

## 9. Security and Privacy

The tool should operate locally by default.

No application source code should leave the developer's environment
merely because the tool is installed.

The Version 1 package should have no network dependency.

## 10. Testing Strategy

Tests should cover:

-   widget selection
-   nested widgets
-   source location availability/unavailability
-   bounds
-   hierarchy
-   annotation creation
-   context serialization
-   Markdown stability
-   platform-specific behavior where practical

Golden tests may be useful for overlay rendering.

Integration tests should use representative Flutter applications rather
than only synthetic unit tests.
