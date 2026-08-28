# Project Overview — Flutter Agentation

## Overview

**Flutter Agentation is NOT an AI coding agent.** It is a **developer-first visual inspection and context-generation tool for Flutter** — a bridge between a running Flutter UI and an external AI coding agent (Claude / Codex / Gemini / Cursor).

Inspired by Agentation/VisBug for the web, the workflow is:

> Point at something in a running Flutter app → understand exactly what it is (widget type, source file, bounds, hierarchy) → add a developer note → produce high-quality structured Markdown/JSON that an external coding agent can use to modify the real source code.

The external AI owns **code modification**. Flutter Agentation owns **visual understanding + context generation**. See `problem-statement.md:44-69` and `context.md:25-51` for the principle.

## Problem Statement

Modern AI agents can edit Dart well, but developers cannot easily communicate **visual** intent:

- "This button is too low." / "This spacing feels wrong." / "Move this card slightly right."

Today they must manually find: which widget, which screen, which file (`lib/screens/home.dart:143`), which hierarchy (`Scaffold → Column → Card → ElevatedButton`), and the current visual state.

Browser tools solve this by inspecting the DOM and mapping to source. Flutter has no DOM — it has an Element/Widget/RenderObject tree. Flutter Agentation solves the same problem using Flutter's **Element APIs, RenderObject/bounds, hit-testing, and debug inspection facilities**, producing structured context for the external agent. Source: `problem-statement.md:1-42`.

## Goals

1. **V1 — Inspect Mode (current scope)**: activate → select widget → see widget identity/source/bounds/hierarchy/properties → add textual note → generate deterministic Markdown → copy to clipboard — no AI calls, no source mutation, local-only. Success = developer can paste context into an external agent and the agent can locate the widget without rediscovery. See `spec.md:35-105`, `problem-statement.md:74-79`.
2. **Clean extension path to V2 — Design Mode**: temporary visual overrides (move/resize/color/typography) without rewriting Dart — serialized as change descriptions for the agent. Must not be built now, but V1 architecture must leave the seam. See `context.md:96-124`, `architecture.md:67-82`.
3. **Clean extension path to V3 — MCP**: expose the same context model via an MCP server so external agents can fetch inspection data programmatically (agent-agnostic). V1's exporter and V3's adapter must share **one source of truth** (`architecture.md:83-311`, `context.md:126-144`).

## Core User Flow (V1 — Inspect Mode)

```
Start Flutter app
  → Activate Agentation (overlay on)
  → Select / point at widget (hit-testing)
  → Inspect: widget type, source file:line:column, bounds, hierarchy, runtime properties
  → Add feedback (textual annotation: "Make this more rounded")
  → Generate context (Markdown + optional JSON + screenshot metadata)
  → Copy Markdown
  → Paste into external coding agent
  → External agent modifies source → Developer reviews in Git
```

See `spec.md:16-33` (FR-001–FR-014) and `architecture.md:1-48` (Overlay → Selection Engine → Resolver → Collector → Annotations → Exporter).

## Target Audience

- **Primary**: Flutter developers already using an external AI coding agent (Claude Code / Codex / Cursor / Gemini) who need to communicate visual changes precisely.
- **Secondary**: Teams doing UI QA on Flutter apps across Android/iOS/Web/Desktop — one codebase, one inspection tool. Target platforms long-term: Android, iOS, Web, Windows, macOS, Linux (`context.md:58-70`).
- **Anti-audience for V1**: users expecting auto code-gen, chat AI, or a full IDE — explicitly non-goals (`problem-statement.md:107-115`).

## Success Metrics (V1 Gate)

Per `problem-statement.md:117-129`, `spec.md:180-193`, `build-instructions.md:191-196`:

- Demo app: can select multiple widget types + nested widgets and always get bounds + hierarchy
- Source location shown when available, **gracefully unavailable** otherwise (no fabrication) — `spec.md:FR-005`, `architecture.md:40`
- Annotation + Markdown generation + clipboard copy works for every selection
- Markdown is deterministic and agent-consumable (sample in `spec.md:134-175`, `architecture.md:166-195`)
- No network dependency, no Dart source mutation (`spec.md:FR-012`, `FR-013`, `decisions.md:Decision 002/011`)
- `flutter analyze` zero issues, tests cover selection / bounds / hierarchy / serialization / Markdown stability
- Clean module seams exist for V2 (visual override) and V3 (MCP) without implementation — `decisions.md:Decision 004/005`, `architecture.md:67-311`
