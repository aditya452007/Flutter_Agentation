# AI Workflow Rules — Flutter Agentation

## Approach

Spec-driven, incremental. `spec.md` is the feature spec; `context.md`/`architecture.md`/`design-statement.md`/`decisions.md`/`build-instructions.md` are the governing docs synthesized into this `context/` folder. Always implement **against those specs** — do not infer behavior from scratch. Before writing any Dart, load the relevant skill(s) and follow them. **No code before the Fork-vs-Build decision and spec acceptance gate** (`build-instructions.md:Mandatory First Phase + Completion Criteria`).

Note on skills: user said Next.js-specific scales/skills "might not be so relevant there is no need to instal them" — do not install web scales. Use the embedded `.agents/` skills (folder-structure mobile tree, design-patterns stack-mobile, ssdlc where applicable) and adapt them to Flutter inspection semantics.

## SDLC Workflow — Adapted to build-instructions.md + Agent.md

Every work unit follows this sequence (Agent.md Steps 0–6 map onto build-instructions phases):

1. **Reconnaissance** (MANDATORY FIRST — `build-instructions.md:01-25`) — inspect entire repo: structure, package boundaries, Flutter/Dart versions, dependencies, existing tests, README, build scripts, lint config, any existing inspector/overlay/MCP infra. Then study: Widgetation, Flutter Pintap, Flan/flan_flutter, Flutter DevTools Inspector, WidgetInspector, Element/RenderObject/hit-test APIs. Do not fork yet.
2. **Fork-vs-Build Assessment** (`build-instructions.md:Fork-vs-Build Decision`) — compare source-selection, source-location, hierarchy/bounds extraction, overlay, annotation, platform support, deps, license, quality, maintenance, extension points, AI coupling. Decide: reuse / depend on / adapt / fork / implement independently. Record as ADR in `context/decision.md` and root `decisions.md`.
3. **Specify/Clarify** — `spec.md` already exists as the V1 spec (FR-001–FR-014, Non-Functionals, Suggested Markdown, Acceptance Test). If gaps appear during reconnaissance, ask via open code questions and record answers.
4. **Plan** — technical context, architecture seams (see `architecture.md`), data model (ContextModel: facts/intent/visual stub), research from step 1–2. Use `design-patterns` stack-mobile + `folder-structure` mobile tree if a package layout is materialized.
5. **Tasks** — dependency-ordered tasks per `build-instructions.md:Git Workflow` sequence: core models → resolver → selection engine → overlay → annotations → exporter → clipboard → demo → tests/hardening.
6. **Analyze** (optional) — cross-artifact consistency: does `flow.md` match code call map, does `ui-context.md` match overlay widgets, does `decision.md` capture every >5s choice.
7. **Implement** — execute tasks one at a time, small commits (`build-instructions.md:Git Workflow`). Each commit: `dart format → flutter analyze → flutter test → git diff` before commit.

**Hard gates**:
- Gate 1: reconnaissance + Fork-vs-Build ADR accepted — no pipeline code before it.
- Gate 2: V1 scope gate — no V2 visual manipulation (move/resize/color/typography) and no V3 MCP before V1 acceptance is green.

## Scoping Rules

- One pipeline stage at a time (Overlay, SelectionEngine, Resolver, Collector, Exporter — not all at once).
- Prefer small, verifiable increments — each can be checked with `flutter analyze` + unit/widget test, not a speculative large change.
- Do not combine unrelated boundaries in one step (e.g., overlay rendering + MCP server).

## When to Split Work

Split if a step would combine:
- Multiple resolver concerns (bounds vs hierarchy vs source) — do one at a time
- Overlay UI + pipeline logic
- Behavior not defined in `spec.md`/`architecture.md`
- Demo app features unrelated to inspection

If verification is not quick (`flutter analyze` + relevant tests), the scope is too broad.

## Skill Loading Order (Flutter Inspection–adapted)

Before implementing any stage, load in this priority order:

1. **`DESIGN-PSYCHOLOGY.md`** — where relevant to panel UX (cognitive load, hierarchy clarity)
2. **`tech-selection`** — only if a stack choice reopens (already Flutter — skip unless user requests change)
3. **`folder-structure`** — materialize **mobile** canonical tree (`references/mobile.md`) into `lib/src/overlay|selection|resolver|context|annotation|exporter` — not the Next.js frontend tree. Use only after the Fork-vs-Build decision (structure may depend on it).
4. **`design-patterns`** — use **`stack-mobile.md`** card (`Screen → Controllers → Services → Repositories` idea maps to `Overlay → SelectionEngine → WidgetResolver → ContextCollector`). Keep modules small, explicit interfaces, immutable models.
5. **`ssdlc`** — only for clipboard/screenshot boundaries and ensuring local-only (no network exfil); minimal for V1.
6. Design skills as needed — `design-basics` / `premium-design` translate to **Material 3** (`ui-context.md`), not Tailwind/Astryx.

Skills **not relevant** for V1 inspection and skipped unless explicitly requested:
- `sitemap`/`user-flows` for routed apps — the tool is an overlay, not a set of routes (use `flow.md` pipeline instead)
- `tech-selection` web default stack (Next.js/Tailwind/shadcn/SSR) — superseded per ADR-004
- `performance_engineering` web Core Web Vitals — use Flutter perf (widget rebuilds, raster/UI jank) instead
- Any `npm install` / `npx` scaffolding — replaced by `flutter create` / `dart pub add` when a package/example is needed

## Component Selection Protocol (Flutter — tool overlay)

1. For overlay UI, reference **Material 3 widget catalog**, not `DESIGN.md` web libraries. `DESIGN.md` stays as inspiration only.
2. If user describes UI vaguely, translate to Flutter widget names: "the thing around the selected widget" → `SelectionHighlight`/`Container` border; "the dark layer behind popup" → `ModalBarrier`.
3. Check Flutter M3 first for standard patterns; motion via implicit animations / `flutter_animate` — not Framer/GSAP.
4. Own the primitives — ship them in `lib/src/overlay/widgets/` rather than adding a heavy third-party widget kit.

## Project Structure Enforcement (Package)

- **Package**: `lib/agentation.dart` public barrel + private `lib/src/**` stages — see `architecture.md:Project Layout`.
- **Demo**: `example/` sibling with `lib/main.dart`.
- **No flat `lib/components/`** — group by stage.
- **No public re-export of internals** — consumers import only `package:agentation/agentation.dart`.
- **Verification**: `flutter analyze` + barrel lint; reviewers check that `lib/src/` is not exported to consumers.

## Handling Missing Requirements

- Do not invent behavior not in `spec.md` / `architecture.md` / `context/decision.md`.
- If ambiguous, ask via open code questions and record the answer as an ADR/context update before implementing.
- If missing, log as an open question in `progress-tracker.md` — do not guess.

## Protected Files (beyond Agent.md:Protected Files)

Do not modify unless explicitly instructed:
- `lib/agentation.dart` public surface — changes require an ADR
- `lib/src/**/exporter` deterministic format — changes require snapshot update + ADR
- `pubspec.yaml` deps — no large dependency added without the Fork-vs-Build ADR
- Past entries in `context/decision.md` / `decisions.md` — append only
- Generated `*.freezed.dart`, `*.g.dart` — treat as build output

## Keeping Docs in Sync

| Change topic | Update this file |
|--------------|------------------|
| Product vision/philosophy/versions | `context/project-overview.md` (and upstream `context.md`, `problem-statement.md`) |
| Modules/pipeline/seams/invariants/layout | `context/architecture.md` (and upstream `architecture.md`) |
| UI tokens/overlay/panel/motion | `context/ui-context.md` (and upstream `design-statement.md`) |
| Every meaningful choice (library/fork/state/routing) | `context/decision.md` + root `decisions.md` (append ADR) — see `build-instructions.md:Fork-vs-Build` |
| Widget/pipeline/export flows + call map | `context/flow.md` |
| Conventions/quality/lint/test gates | `context/code-standards.md` |
| Workflow/phases/gates | `context/ai-workflow-rules.md` (this file) + `build-instructions.md` |
| Where we are / what's next / open Qs | `context/progress-tracker.md` every task |

> `progress-tracker.md` + `flow.md` + `decision.md` are the three **living** files — synced on EVERY task (AGENTS.md: Context Sync Protocol).

## Reading the Three Living Files

Before every task, read in order:
1. `progress-tracker.md` — phase, done, next, open questions
2. `flow.md` — pipeline, widget call map, request/response flows
3. `decision.md` — every decision + why (needs the Fork-vs-Build ADR before implementation)

## Before Moving to the Next Unit

Gate before starting the next git step (`build-instructions.md`):

1. Unit works end-to-end for its scope (`flutter analyze` zero issues, relevant tests green)
2. No invariant in `architecture.md` was violated (optional source/bounds handled, one ContextModel)
3. Docs synced: updated `progress-tracker.md` + `flow.md`/`decision.md` if needed
4. `dart format .` done; `git diff` reviewed (no `build/`, `.dart_tool/`, generated drift, or secrets)
5. Small logical commit made — not "updates" or "changes"
6. Package still has no network/AI/MCP deps and exporter remains deterministic

## Prohibited Practices

- No code before reconnaissance + Fork-vs-Build ADR — first commit is **reconnaissance + documentation**, not feature code (`build-instructions.md:Git Workflow step 1`).
- No large dependency / fork introduced merely because it implements part of the feature — assessment first.
- No AI/LLM/MCP/visual manipulation in V1 (`spec.md:FR-012/013`, `decisions.md:D-002/012`).
- No full design-mode UI or persistent history system in V1 (`design-statement.md:116-120`, `decisions.md:D-008`).
- No silently modifying host app behavior when inspection is off.
- No fabricating source locations — optional `T?` with unavailable branch.
- No single-library default without ADR — even for state/motion.
