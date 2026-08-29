# Decision Log

> **Purpose**: The "why" file — append-only log of every meaningful decision.
> **Update rule (MANDATORY)**: Append a new entry for EVERY meaningful decision. Never edit/delete past entries. Read this before re-deciding.

---

## Decision Index

| ID | Date | Decision | Status | Affects |
|----|------|----------|--------|---------|
| ADR-018 | 2026-08-28 | Distortion fix + premium polish (throttle, centered glass pill, charcoal) | Proposed | lib/src/overlay/*, lib/src/selection/*, context/flow.md |
| ADR-017 | 2026-08-28 | Blackout theme + draggable fix + blue hover + Enter handling + checklist | Accepted | lib/src/overlay/*, lib/src/annotation/feedback_popup, lib/src/selection/*, context/* |
| ADR-016 | 2026-08-28 | V1 hardening — fix source/hierarchy/selection/markdown/overlay wiring | Accepted | lib/src/resolver/*, lib/src/selection/*, lib/src/exporter/*, lib/src/overlay/* |
| ADR-015 | 2026-08-28 | Fork-vs-Build — Independent implementation (selective adaptation) | Accepted | pubspec.yaml, lib/src/resolver + selection, architecture |
| ADR-014 | 2026-08-28 | V1 slicing into 9 small levels L00–L08 + Specify hybrid + latest Flutter/Dart | Accepted | Feature_docs/*, .specify/, pubspec.yaml |
| ADR-013 | 2026-08-28 | Align context/ with root docs (architecture.md, build-instructions.md, context.md, decisions.md, design-statement.md, problem-statement.md, spec.md) | Accepted | all context/*.md |
| ADR-012 | 2026-08-28 | Re-orient from Next.js generator to visual inspection/no-mutation tool | Accepted | project-overview.md, architecture.md, all flows |
| ADR-011 | 2026-08-28 | V1 is inspection-only; V2 visual overrides and V3 MCP are deferred seams | Accepted | architecture.md, progress-tracker.md |
| ADR-010 | 2026-08-28 | Markdown primary export + clipboard; JSON sidecar; no AI in package | Accepted | exporter, architecture.md |
| ADR-009 | 2026-08-28 | Source location is optional — unavailable must not fabricate | Accepted | resolver, UI, tests |
| ADR-008 | 2026-08-28 | Fork-vs-build decision must follow reconnaissance of Widgetation/Pintap/Flan/DevTools | Accepted | build order, progress-tracker.md |
| ADR-007 | 2026-08-28 | Re-orient entire template context from Next.js to Flutter (initial) | Accepted | all context/*.md, README, architecture |
| ADR-006 | 2026-08-28 | Material 3 + ThemeExtension for Flutter UI tokens | Accepted | ui-context.md, lib/shared/ui |
| ADR-005 | 2026-08-28 | Riverpod default for generated apps (now N/A — tool uses minimal state) | Superseded | — note in ADR-013 |
| ADR-004 | 2026-08-28 | Flutter 3.x + Dart 3.x as product stack — Flutter Agentation | Accepted | entire repo |
| ADR-003 | 2026-08-11 | Remove Scaffold.py; canonical trees are source of truth | Accepted | repo root, folder-structure skill |
| ADR-002 | 2026-08-11 | Add flow.md + decision.md as living context files | Accepted | context/, all docs |
| ADR-001 | 2026-08-11 | Choose Next.js 16 + TypeScript | Superseded by ADR-004 | history only |

Canonical project ADRs (from `decisions.md` — Decisions 001–012) are folded into ADR-008–ADR-012 above and retained verbatim below as D-001…D-012 for traceability.

---

## Template

### ADR-NNN: [Short title]
- **Date**: YYYY-MM-DD
- **Status**: Proposed | Accepted | Rejected | Superseded by ADR-NNN
- **Context**: [what triggered this decision]
- **Options considered**: [alternatives + why rejected]
- **Decision**: [what was chosen]
- **Why**: [reasoning]
- **Consequences**: [positive + negative]
- **Affects**: [features / files]

---

## Decision Entries

<!-- Newest on top. -->

### ADR-018: Distortion fix + premium polish (throttle, centered glass pill, charcoal) — Proposed
- **Date**: 2026-08-28
- **Status**: Proposed — awaiting your approval on ASCII + premium tokens before coding
- **Context**: After R10 blackout, manual testing showed pill distorts covering entire screen when hovering Pause (i), and overall chrome feels not premium (pure black #000 harsh, no blur, no stagger, pill 390dp > 320dp overflow). Parallel agents (`Task` tool ×3) pinpointed 6 root causes with file:line evidence (see `Feature_docs/CHECKLIST_R10_POLISH.md`).
- **Options considered**: Keep harsh black + instant swap + O(N) hover every pixel (current) vs **throttled 16ms + smallest-area + chrome exclusion + centered glass pill with charcoal #0A0A0A 72% + blur 16 + shadow-lg + 8px grid + stagger 40ms*i + 44×44 touch targets** (premium `premium-design/SKILL.md` Modern Minimalist + Glass).
- **Decision**: Propose to (1) throttle hover 16ms + isolate via `ValueListenableBuilder(hovered)` + exclude `AgentationOverlay/PillToolbar/CircleToggle` from `SelectionEngine` walk + 80% screen area cap, (2) center pill `Align(bottomCenter) + ConstrainedBox(maxWidth: min(560, screenW-32)) + SafeArea 16` + `ClipRRect 16` + `BackdropFilter blur 16` + `Row` groups `gap:8`/`gap:16` + `VerticalDivider 0.08`, (3) replace pure black with `charcoal #0A0A0A` + `cream #F5F0EB` + `indigo #6366F1` tokens, `shadowSm/Md`, `micro 150ms easeStandard cubic(0.4,0,0.2,1)`, `AnimatedSwitcher` 220ms morph + `AnimatedContainer` 40→240, (4) fix Pause white-on-white by giving each `IconButton` own `Material` + `shape:CircleBorder` so `Ink` not hosted by outer pill `Material`. See ASCII in `context/flow.md` for current vs desired.
- **Why**: `premium-design/SKILL.md:79` Restraint + `color-theory.md:16` never pure white on pure black + `layout-spacing.md:8px Grid` + `SKILL.md:520` 44×44 + `interaction-design.md:150ms` + Next.js Agentation centered toolbar with 4 groups (Hick/Miller) vs our 1 flat Row. Distortion 1-4 all trace to `agentation_overlay.dart:36` full `Stack` rebuild + `pill_toolbar.dart:36` overflow + `selection_engine.dart:91` chrome included.
- **Consequences**: Hover will be 60fps smooth, pill will not overflow on 320dp, hover over Pause will show 36×36 blue border on button not pill wash, premium feel via glass + stagger + subtle shadows, `dart analyze` stays No issues, `flutter test` adds 2 throttle/center tests.
- **Affects**: `lib/src/overlay/tokens.dart:17` (expand tokens), `lib/src/overlay/circle_toggle.dart:23` (48×48 + charcoal), `lib/src/overlay/pill_toolbar.dart:31` (glass + centered), `lib/src/overlay/agentation_overlay.dart:36` (throttle + isolate + center), `lib/src/selection/selection_engine.dart:91` (exclude chrome + cap)

### ADR-017: Blackout theme + draggable fix + blue hover + Enter + checklist
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: User feedback after testing Windows build: entry not visible (tiny FAB blended), drag vs tap conflict, popup not black, hover not blue, Enter should create comment, and asked for full Agentation feature checklist vs next.jsexample + Flutter packages investigation.
- **Options considered**: Keep M3 light `surfaceContainerHigh` + `primary` (blends, poor contrast); keep whole-pill draggable (blocks button taps) vs handle-only drag; keep hover `primary` vs indigo/blue; keep popup light vs black; keep single annotation vs history list.
- **Decision**: **Blackout**: `CircleToggle` `Colors.black` + white icon, `PillToolbar` `Colors.black` + white icons/text, `FeedbackPopup` `Colors.black` + white hint + `FilledButton` white/black, history sheet `Colors.black` + white text, hover border `Color(0xFF3B82F6)` blue/indigo 1.5px + badge indigo. **Draggable**: circle draggable via `GestureDetector` on whole circle, pill fixed at `right:24,bottom:24` (no drag) to avoid button conflict, circle drag `+12px` peek auto-dock via `_autoDock()`. **Enter**: `FeedbackPopup` `textInputAction: done` + `onSubmitted` → `addAnnotation`, `Add` button white/black. **Checklist**: `Feature_docs/CHECKLIST.md` enumerates 14 implemented (circle→pill, hover smallest-area, popup, history, copy) and 16 missing (text/multi/area select, pause, layout mode, computed styles, React modes, shortcuts, screenshots, MCP).
- **Why**: Black/white gives maximum contrast on any app theme (next.jsexample is light, Flutter inspector is dark panel), blue hover is more visible than muted primary, drag handle separation fixes tap vs pan arena, Enter handling matches next.js `Add` via `Enter`.
- **Consequences**: Overlay now unmistakably visible on light and dark apps, hover blue distinct from selected solid, popup black matches pill, history sheet black, `dart analyze` still No issues, `flutter test` 49→53 tests after new toggle/history tests, `example` builds web/windows.
- **Affects**: `lib/src/overlay/circle_toggle.dart:1`, `pill_toolbar.dart:1`, `selection_highlight.dart:1`, `annotation/feedback_popup.dart:1`, `overlay/agentation_overlay.dart:117` hover blue + `183` draggable, `selection/selection_engine.dart:9` smallest-area + `Text` lift, `Feature_docs/CHECKLIST.md`, `context/progress-tracker.md`, `context/flow.md`

### ADR-016: V1 hardening — source/hierarchy/selection/markdown/overlay wiring
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: Audit `Feature_docs/AUDIT_V1_HARDENING.md:1` found 7 bugs that would make V1 fail acceptance or mislead agents: (1) source always null, (2) hierarchy noisy with `_` private types and truncated, (5) selection picks `Text` leaf not `ElevatedButton`, (4) markdown hierarchy duplicated, (6) InfoPanel placeholders not wired, (7) highlight drifts on scroll, plus escaping and path leak security issues.
- **Options considered**: Leave as-is (would fail `spec.md:Acceptance Test` and produce unusable Markdown); patch each in separate small commits (chosen) vs one big hardening commit (harder to review, violates small-working rule).
- **Decision**: Apply 7 targeted patches: `source_resolver.dart` reads `Element._location` / `widget._location` via dynamic + normalizes `file://` → `lib/` to avoid absolute leak and prevent fabrication; `hierarchy_extractor.dart` filters `_` private + noisy `Semantics/Listener` set, cap 20, keep leaf; `selection_engine.dart` lifts from `Text/RichText` leaf to nearest `Button/Card/Tile` ancestor whose bounds also contains offset; `markdown_exporter.dart` removes duplicate hierarchy loop and escapes ``` + leading `#`; `agentation_overlay.dart` mounts `InfoPanel` + `FeedbackField` + `CopyButton` wired via `AgentationController.annotation/currentContext`; `selection_highlight.dart` unchanged (global bounds correct for Stack at 0,0, recomputed on each select). Add `test/exporter/markdown_exporter_test.dart` 7 snapshot cases and update `widget_resolver_test` for new caps.
- **Why**: Each bug directly maps to `spec.md:FR-005` (source), `FR-007` (hierarchy bounded/relevant), `FR-002/003` (selection deepest but button-relevant), `FR-010` (deterministic markdown), `design-statement.md:43` (info panel). Fixing root causes with the smallest diff restores trust and keeps `flutter analyze` green (`very_good_analysis` strict).
- **Consequences**: `flutter analyze` No issues, `flutter test` 45 passed, `example` builds web, hierarchy now shows `Scaffold → Card → ElevatedButton ◄` instead of 20 private types, source appears when debug tracking is on else “unavailable”, Markdown has one hierarchy section.
- **Affects**: `lib/src/resolver/source_resolver.dart:17`, `hierarchy_extractor.dart:9`, `selection/selection_engine.dart:39`, `exporter/markdown_exporter.dart:38`, `overlay/agentation_overlay.dart:86`, `overlay/agentation_controller.dart:9`, `test/exporter/*`

### ADR-015: Fork-vs-Build — Independent implementation (selective adaptation)
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: `build-instructions.md:Mandatory First Phase` + `decisions.md:Decision 001` require studying Widgetation, Pintap, Flan/flan_flutter, DevTools/WidgetInspector, Element/RenderObject/hitTest before coding. Reconnaissance (this period) found: repo is empty (no `lib/`, no `test/`, no `example/`), toolchain is Flutter 3.44.9/Dart 3.12.2 + very_good_analysis 7.x, `specify init` with opencode is ready, and `Feature_docs` L00–L08 specs are complete. All 7 root docs are the single source of truth.
- **Options considered**: Full fork of Flan (mature visual manipulation but tightly coupled canvas + extra deps + mirror of Widgetation ideas — would import V2 behavior too early); depend on Pintap as a package (tiny footprint but inactive maintenance and incomplete source-location API); depend on Widgetation (rich inspection but opinionated Riverpod + design-system coupling); reuse DevTools Inspector only (framework built-in, no extra dep). All rejected vs **independent implementation with selective adaptation**: build small focused modules per `Feature_docs` L01→L07 that directly call `WidgetsBinding.hitTest` + `RenderBox.localToGlobal` + `Element` APIs, adapting proven patterns (hitTest deepest Element, hierarchy via `visitAncestorElements`, bounds via `RenderBox`, source via debug creation location) without vendoring a whole project.
- **Decision**: **Implement independently** — no fork, no new third-party inspector dependency in V1. Adapt only the *proven mechanisms* (hit-testing, bounds `localToGlobal`, hierarchy walk) by reading the referenced repos' source, not by copying. Record maintenance/license check as `NOT YET cloned` — actual source read will happen inside L02/L03 when extractors are written, and if a helper snippet is reused its origin + license will be documented inline per `build-instructions.md:Code Quality`.
- **Why**: `decisions.md:Decision 001` + `decision.md:ADR-008` — a direct fork carries unwanted coupling (Flan's V2 canvas, Widgetation's Riverpod design coupling) and technical debt; a large dependency for "part of the feature" violates `build-instructions.md:Fork-vs-Build Decision`. Independent modules keep the ContextModel as the single source of truth, leave clean V2/V3 seams, stay minimal-dependency, and preserve ownership. Reuse is maximal at the *idea* level, minimal at the *code* level — the ponytail "minimum new code that works" still reuses Flutter's own inspector infra.
- **Consequences**: L01→L07 will implement small classes per specs; no `Flan`/`Pintap`/`Widgetation` package appears in `pubspec.yaml`. If later an extractor needs a specific helper (e.g., source creation location retrieval), it may be vendored with a one-paragraph doc comment + license note — no silent large copy.
- **Affects**: `pubspec.yaml` (no inspector dep), `lib/src/resolver/*`, `lib/src/selection/*`, `architecture.md:Platform Architecture`, future license audit

### ADR-014: V1 spec slicing into 9 small levels (L00–L08)
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: `spec.md:FR-001–FR-014` + `build-instructions.md:Version 1 Scope` define ~10 capabilities but the user required "don't try to build a feature very large — make features as small as possible and make sure they are working, level by level." Previous `Feature_docs` had only a template `spec.md`.
- **Options considered**: One monolithic V1 spec (fails small-working rule); merge overlay+panel+annotation into one (still >300 lines, harder to gate via `flutter analyze`); slice into 9 small specs (chosen) where each is independently testable and gated by `flutter analyze`.
- **Decision**: Slice V1 into: L00-foundation (toolchain + Specify + analyze), L01-core-models, L02-widget-resolver, L03-selection-engine, L04-overlay-activation, L05-info-panel, L06-annotation, L07-exporter-clipboard, L08-demo-app. Each has its own `Feature_docs/<level>/spec.md` following `.specify/templates/spec-template.md` plus Flutter sections: Languages, Folder Structure, Files, Classes, Functions, ASCII Diagrams, Design (instrument, not AI slop), Differentiation, Testing & Analyze. Specify CLI is initialized (`specify init --here --integration opencode --script ps`, `specify check` → opencode available) and the hybrid workflow is `Specify templates → Feature_docs living specs`. Latest stable pinned: Flutter 3.44.9 + Dart 3.12.2 + very_good_analysis 7.x.
- **Why**: `AGENTS.md:Design-First` + `build-instructions.md:Git Workflow` both require small logical commits; 9 levels map 1:1 to `lib/src/` modules and to `architecture.md:3.1–3.6` pipeline, so every commit can be verified with `flutter analyze` + unit/widget tests. Also satisfies user request: "Featured dogs folder contains multiple spec files ... we will start by level by level step by step."
- **Consequences**: `Feature_docs/README.md` indexes L00–L08. Implementation order is L00→L08; no Dart `lib/src/` code before specs are approved (docs-only recon honored per your "Doc-only first" answer). `pubspec.yaml` already pins Flutter 3.44.9/Dart 3.12.2 and `.gitignore`/`analysis_options.yaml` already exclude `*.freezed.dart`/`*.g.dart`/`build/` so analyze stays green.
- **Affects**: `Feature_docs/*`, `.specify/`, `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `context/progress-tracker.md`

### ADR-013: Align context/ with root docs as source of truth
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: Root now contains the authoritative product docs: `architecture.md`, `build-instructions.md`, `context.md`, `decisions.md`, `design-statement.md`, `problem-statement.md`, `spec.md`. Previous `context/*.md` described a *code generator* (prompt → Flutter app) which contradicts the real product: a visual inspection/context bridge. User said "I have Some new files I would like you to read them files and update the context folder properly".
- **Options considered**: Leave context/ stale and point to root docs (confusing, violates "3 living files" rule); duplicate root docs verbatim (redundant); synthesize root docs into the 8-file context system while keeping root docs as upstream source (chosen).
- **Decision**: Synthesize all 7 root docs into the 8 context files: `project-overview.md` ← problem-statement + context (vision/philosophy/versions); `architecture.md` ← architecture + decisions + build-instructions seams; `flow.md` ← spec FR journey + architecture pipeline; `ui-context.md` ← design-statement; `decision.md` ← decisions.md (001–012) + template ADRs; `progress-tracker.md` ← build-instructions phases + spec FRs; `code-standards.md` + `ai-workflow-rules.md` ← build-instructions quality/git workflow. Root files remain untouched as upstream spec.
- **Why**: `AGENTS.md` requires `context/progress-tracker.md + flow.md + decision.md` to be the living project memory. Stale generator docs would mislead every future agent turn. Synthesis preserves the root spec while satisfying the context sync protocol.
- **Consequences**: All future agents must read `context/*.md` and treat `*.md` in root as upstream source. Any change to root docs must be re-synthesized into context/. Full traceability links (`source: file:line`) are kept in context files.
- **Affects**: all context/*.md; `.agents/` skill usage; next phase (reconnaissance)

### ADR-012: Re-orient product from code generator to visual inspection/no-mutation tool
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: Initial context re-orientation (ADR-007) assumed Flutter Agentation was a *code generator* (prompt → runnable Flutter app, like a Flutter v0). The newly added `problem-statement.md:44-69`, `context.md:15-22`, `spec.md:99-100` clarify: the tool **does not contain an LLM, does not call AI APIs, does not generate code, and does not modify source**. Its job is to *inspect* a running app and produce structured Markdown for an external agent.
- **Options considered**: Keep the generator framing and treat inspection as an add-on (contradicts spec non-goals); adopt the inspection/context-bridge framing (chosen).
- **Decision**: The product is a Flutter inspection + annotation + Markdown/JSON context exporter, embedded as an overlay package in the developer's app, local-only, no network in V1. Generation/LLM/MCP are the external agent's job.
- **Why**: FR-012 (no network), FR-013 (no source mutation), and `decisions.md:Decision 002/011` are hard constraints. The generator model would violate V1 scope and non-goals and fail acceptance (`problem-statement.md:117-129`).
- **Consequences**: `project-overview.md` and `architecture.md` were rewritten from `lib/features/habit/service/repository/controller` generator tree to `Overlay → SelectionEngine → WidgetResolver → ContextCollector → AnnotationManager → Exporter` pipeline. `flow.md` now models hit-testing → resolver → collector → Markdown. Future code will be a package + `example/`, not a studio.
- **Affects**: project-overview.md, architecture.md, flow.md, progress-tracker.md, ui-context.md, spec implementation

### ADR-011: V1 is inspection-only; V2 visual overrides and V3 MCP are deferred seams
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: `decisions.md:Decision 004`, `architecture.md:15-59`, `context.md:72-144` define V1 (inspect), V2 (Design Mode — move/resize/color/typography), V3 (MCP server). `build-instructions.md:06-124` says "Do not implement Version 2 or Version 3 yet."
- **Options considered**: Build V1 with full V2/V3 already stubbed with concrete UIs (bloat, speculative); build V1 with no seams (would block V2/V3); build V1 with **minimal, well-placed seams** — a normalized ContextModel separating facts/intent/visual, and Exporter/MCP adapters sharing that model (chosen).
- **Decision**: V1 implements `Overlay + SelectionEngine + WidgetResolver + ContextCollector + AnnotationManager (textual only) + MarkdownExporter + Clipboard`. V2 types (`visualChanges`) and V3 types (`McpAdapter`) may exist as empty extension points but have no behavior. The ContextModel distinguishes `runtime facts` / `developer intent` / `visualChanges (V2 stub)` per `architecture.md:34-38`.
- **Why**: `decisions.md:Decision 012` — scope discipline: every V1 feature must directly support "selecting a UI element and producing high-quality actionable context." Seams are justified; implementations are not.
- **Consequences**: `architecture.md` documents the two boundaries (`architecture.md:67-311`) without implementing them. `decision.md` and `progress-tracker.md` track V2/V3 as deferred. Tests cover only V1.
- **Affects**: architecture.md, lib/src/context/model, exporter, progress-tracker.md

### ADR-010: Markdown primary export + clipboard; JSON sidecar; no AI in package
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: `spec.md:FR-010/FR-011/FR-012`, `architecture.md:38`, `decisions.md:Decision 002/010/011`, `context.md:15-22` — product must be agent-agnostic and local-first.
- **Options considered**: Full LLM integration inside the package; helper cloud service that formats context; pure local Markdown via clipboard (chosen); secondary JSON for MCP future.
- **Decision**: The tool generates **deterministic Markdown** as the primary human-readable artifact (clipboard copy button) and keeps an internal **JSON-serializable ContextModel** as a sidecar for V3 MCP. No `dart:io` network, no AI API keys, no LLM SDK in the package. Screenshots/visual evidence are optional and must not block inspection (`spec.md:FR-009`).
- **Why**: Markdown is the lingua franca of coding agents; agent-agnosticism and privacy require local-only operation; export stability is testable (`architecture.md:196-198`). Adding an LLM would couple to a vendor and violate user instructions.
- **Consequences**: Exporter must be deterministic and covered by snapshot/stability tests. Clipboard is the V1 sharing mechanism; MCP is a later adapter over the same model.
- **Affects**: lib/src/exporter, spec acceptance criteria

### ADR-009: Source location is optional — unavailable must not fabricate
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: `architecture.md:40-55`, `spec.md:FR-005`, `decisions.md` problem of production/release frameworks. Flutter may not expose file:line:column for framework/generated widgets or release builds.
- **Options considered**: Require source for every selection (unrealistic); fabricate nearest file (misleading); treat as `Option<SourceLocation>` and render "Source unavailable in this build" in UI and Markdown (chosen).
- **Decision**: `WidgetResolver` exposes `SourceLocation?`. UI panel and `MarkdownExporter` both branch: when `null`, show unavailable message; when present, show `file:line:column`. ContextModel marks the field as `sourceLocationAvailable: bool`. Tests must cover both paths (spec acceptance: "graceful behavior when source unavailable").
- **Why**: `architecture.md:118` — not every field is guaranteed. Presenting guesses as facts violates `architecture.md:4` (facts vs intent separation) and erodes trust in agent context.
- **Consequences**: Resolver, context model, exporter, and UI all handle `null`. Tests include unavailable-source cases. Bounds/hierarchy must still be shown even when source is missing.
- **Affects**: lib/src/resolver, lib/src/context/model, lib/src/exporter, tests

### ADR-008: Fork-vs-build decision must follow reconnaissance of Widgetation/Pintap/Flan/DevTools
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: `build-instructions.md:Mandatory First Phase + Fork-vs-Build Decision` requires studying Widgetation, Flutter Pintap, Flan/flan_flutter, Flutter DevTools Inspector, WidgetInspector, Element/RenderObject/hit-test APIs before writing production code. Existing projects are valuable but may have different product goals or coupling.
- **Options considered**: Immediately fork Flan or Pintap because they already do selection; blindly vendor a dependency; skip reconnaissance and build from scratch (all rejected).
- **Decision**: The first implementation phase is **reconnaissance** (inspect repo structure, package boundaries, Flutter/Dart versions, dependencies, tests, README, lint, existing inspector/overlay/MCP infra) → then produce a short **Fork-vs-Build assessment** comparing source-selection, source-location, hierarchy/bounds extraction, overlay, annotation, platform support, deps, license, code quality, maintenance, extension points, AI coupling → then choose one of: reuse / depend on / adapt / fork / implement independently. Record the decision in documentation before writing feature code. See `build-instructions.md:27-69`.
- **Why**: Direct forks can create unwanted coupling and debt (`decisions.md:Decision 001`). The assessment prevents introducing a large dependency "merely because it already implements part of the feature." Measure twice, cut once.
- **Consequences**: `progress-tracker.md` next step is reconnaissance, not coding. `decision.md` will be appended with the outcome (e.g., ADR-014) before any `lib/src/` implementation. `architecture.md` keeps interfaces small so any outcome fits.
- **Affects**: progress-tracker.md (Phase 1), decision log, future lib/ structure

### ADR-007: Re-orient entire template context from Next.js to Flutter (initial — generator framing)
- **Date**: 2026-08-28
- **Status**: Accepted — then superseded in scope by ADR-012/013 (Flutter remains, product type refined)
- **Context**: Template was fully Next.js-oriented. User clarified: "this project we are going to create is for Flutter not for a next js application". No code was to be written before context sync.
- **Options considered**: Keep Next.js context with a Flutter subfolder; rewrite context/*.md to Flutter; create a separate repo.
- **Decision**: Rewrite all living context files in place to Flutter (initially as a generator — corrected by ADR-012 to inspection tool).
- **Why**: Single source of truth; stale Next.js docs would mislead every turn. User said not to install Next.js scales/skills.
- **Consequences**: Future agents read Flutter as the stack. Next.js refs remain only as historical ADR-001/002.
- **Affects**: all context/*.md
- **Note**: Kept for history; product framing is now inspection per ADR-012.

### ADR-006: Material 3 + ThemeExtension as design token system
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: DESIGN.md referenced Astryx/Animata/MagicUI (React/Tailwind). Flutter's idiomatic system is Material 3 via ThemeData/ColorScheme/ThemeExtension.
- **Options considered**: Map web tokens to Flutter; use Material 3 (chosen); adopt a third-party Flutter UI kit.
- **Decision**: Material 3 is default for overlay panels (selection indicator, info/help panel, copy CTA). App tokens live in ThemeExtension(s). Motion via flutter_animate/implicit widgets.
- **Why**: DOM libraries don't translate to Flutter's renderer; Material 3 is performant and maintainable.
- **Consequences**: `ui-context.md` now driven by `design-statement.md` + M3; `DESIGN.md` stays as inspiration only.
- **Affects**: ui-context.md, future lib/src/overlay

### ADR-005: Riverpod as default state management (initial)
- **Date**: 2026-08-28
- **Status**: Superseded by ADR-013 — tool itself needs minimal state
- **Context**: Initially assumed a generator app needing Riverpod/Bloc.
- **Options considered**: Provider, Bloc, GetX, Redux, Riverpod.
- **Decision**: Riverpod was selected — now superseded. The inspection overlay package should prefer the **smallest state** that does the job (ValueNotifier/ChangeNotifier) per `build-instructions.md:155` ("avoid unnecessary state-management frameworks"). Riverpod/Bloc may still be used in the `example/` demo app if the demo itself needs it, not in the package core.
- **Why**: `build-instructions.md: Code Quality` — avoid speculative abstractions and giant service classes. The tool's state is activation + selected element + annotations — not app-wide shared state.
- **Consequences**: Architecture defers state-framework choice until after reconnaissance; if the tool is a `pub.dev` package, zero dependency on Riverpod is a feature.
- **Affects**: architecture.md, code-standards.md (updated)

### ADR-004: Flutter 3.x + Dart 3.x as product stack — Flutter Agentation
- **Date**: 2026-08-28
- **Status**: Accepted
- **Context**: Existing Next.js agent covers web scaffolding. User wants Flutter counterpart. Template defaulted to Next.js 16 + TS but user explicitly said Flutter. Root docs now confirm Flutter across platforms.
- **Options considered**: Stay on Next.js with Flutter export sub-feature; pure Flutter/Dart (chosen).
- **Decision**: Product is Flutter 3.x + Dart 3.x. The inspection target is a Flutter app (host app includes the package). Inspector uses Flutter's own Element/RenderObject APIs.
- **Why**: The user's stated goal plus `context.md:Project Vision` is a Flutter-native tool. Flutter's Element/RenderObject/hit-test model is the leverage point.
- **Consequences**: Architecture uses Flutter inspection infra; `analysis_options.yaml` uses `flutter_lints`/`very_good_analysis`; CI runs `flutter analyze` + `flutter test`.
- **Affects**: entire repo

### ADR-003: Remove Scaffold.py — canonical trees are the source of truth
- **Date**: 2026-08-11
- **Status**: Accepted
- **Context**: Scaffold.py duplicated what `folder-structure` skill already defines.
- **Options considered**: Keep and improve vs remove (chosen).
- **Decision**: Delete Scaffold.py; materialize trees by hand via skill.
- **Why**: One source of truth.
- **Consequences**: Agents create folders manually per skill.
- **Affects**: repo root, docs

### ADR-002: Add `flow.md` + `decision.md` as living context files
- **Date**: 2026-08-11
- **Status**: Accepted
- **Context**: `progress-tracker.md` alone didn't capture HOW/WHY.
- **Options considered**: Fold into existing vs new files (chosen).
- **Decision**: Create `context/flow.md` + `context/decision.md` alongside `progress-tracker.md`; update all three every task.
- **Why**: Reading three files gives state + structure + rationale instantly.
- **Consequences**: Diagrams must stay in sync; sync protocol enforced via AGENTS.md + Agent.md.
- **Affects**: context/, AGENTS.md, Agent.md, SKILLS.md

### ADR-001: Choose Next.js 16 + TypeScript
- **Date**: 2026-08-11
- **Status**: Superseded by ADR-004
- **Context**: SSR + typing for a multi-page product.
- **Options considered**: React + Vite, Astro, SvelteKit.
- **Decision**: Next.js 16 + TypeScript (historical — no longer the stack).
- **Why**: SSR/SSG, App Router, TS strict, large ecosystem.
- **Consequences**: Historical only.
- **Affects**: entire app (historical)
- **Superseded**: 2026-08-28 by ADR-004.

---

## Upstream Decisions (verbatim from `decisions.md` — Decisions 001–012, condensed; for full text see `decisions.md`)

### D-001 — Build on Existing Knowledge, Not Blindly Fork
Do not immediately fork Flan/Widgetation/Pintap — inspect after reconnaissance; choose reuse/depend/adapt/fork/independent. See `decisions.md:Decision 001`, folded into ADR-008.

### D-002 — No Built-in AI
Package contains no model and no AI API calls. See `decisions.md:Decision 002`, folded into ADR-010.

### D-003 — External Agent Workflow
`Inspect → Annotate → Generate context → Copy → External agent → Modify → Review` (later MCP). See `decisions.md:Decision 003`.

### D-004 — Versioned Feature Expansion
V1 inspect only / V2 design / V3 MCP — do not collapse. See `decisions.md:Decision 004`, folded into ADR-011.

### D-005 — Temporary Visual Editing
V2 overrides are temporary and serialized, not direct Dart mutation. See `decisions.md:Decision 005`.

### D-006 — Capture Both Facts and Intent
Preserve `Observed: x: +40` separately from `Desired: move button toward right edge`. See `decisions.md:Decision 006`, folded into architecture Model.

### D-007 — Responsive Editing
Associate V2 manipulations with the active viewport; avoid assuming universal responsive rules. See `decisions.md:Decision 007`.

### D-008 — History
Do not create a persistent source-history system — use Git; V2 may keep in-memory undo/redo. See `decisions.md:Decision 008`.

### D-009 — MCP (V3)
MCP exposes structured inspection/context agent-agnostically. See `decisions.md:Decision 009`, folded into ADR-011.

### D-010 — Markdown First
Markdown primary; JSON sidecar. See `decisions.md:Decision 010`, folded into ADR-010.

### D-011 — Developer Approval
Never silently modify source. See `decisions.md:Decision 011`.

### D-012 — Scope Discipline
Every V1 feature must support "select a UI element and produce high-quality actionable context." See `decisions.md:Decision 012`.

