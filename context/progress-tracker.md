# Progress Tracker — Flutter Agentation

Update this file after every meaningful change. Must stay consistent with root docs: `spec.md`, `architecture.md`, `build-instructions.md`, `context.md`, `decisions.md`, `problem-statement.md`, `design-statement.md`.

## Current Phase

**Phase 0 — Context Sync (COMPLETE)**
**Phase 1 — Foundation & Specs (COMPLETE — this commit: L00–L08 specs)**
**Phase 2 — Reconnaissance + Fork-vs-Build ADR-015 (NEXT — doc-only per your answer)**
**Phase 3 — Level-by-level implementation (after approval of specs + ADR → plan → tasks)**

V1 scope locked to `spec.md:FR-001–FR-014` + `build-instructions.md:Version 1 Scope`. No V2 (visual manipulation) or V3 (MCP) in implementation.

## Current Goal

Spec phase is **specs-only** per your instruction: "currently you only write specs." L00–L08 specs are drafted and await your approval before any Dart `lib/src/` code is written or `example/` scaffolded. Next gate: **spec approval** → reconnaissance (doc-only) → Fork-vs-Build ADR → then level-by-level implement with `flutter analyze` / `dart analyze` green on every commit.

## Completed (this commit — spec phase)

- **Toolchain upgraded to latest**: Flutter **3.44.9** stable (`flutter --version: 3.44.9 / Dart 3.12.2 / DevTools 2.57.0` verified), `pubspec.yaml:environment sdk ">=3.12.2 <4.0.0", flutter ">=3.44.9"` + `very_good_analysis ^7.0.0` + `flutter_lints ^5.0.0` (sorted), `flutter pub get` + `flutter analyze` → **No issues found!** (`dart analyze` also green).
- **Specify CLI initialized**: `specify init --here --integration opencode --ignore-agent-tools --force --script ps` → `.specify/` with `templates/spec-template.md` + `plan-template.md` + `tasks-template.md` + `memory/constitution.md` + `scripts/powershell/*` (`specify check` → `opencode available`). Hybrid workflow chosen per your answer: Specify templates as guidance, living specs in `Feature_docs/*/spec.md`.
- **`.gitignore` + `analysis_options.yaml` hygiene**: `.gitignore:12-16` ignores `*.freezed.dart`, `*.g.dart`, `*.gr.dart`, `.dart_tool/`, `build/`, `coverage/`, `l10n/generated/`; `analysis_options.yaml:analyzer.exclude:2-8` mirrors those ignores (generated files never break `flutter analyze`). Pattern `specify/memory/*.md` also handled.
- **Synthesized `context/`** (previous commit) — 7 root docs → 8 context files, generator framing removed.
- **Wrote 9 small, level-by-level V1 specs in `Feature_docs/`** (approved slice via open-code questions):
  - `L00-foundation/spec.md` (163 lines) — pubspec + lint + gitignore + Specify + analyze gate
  - `L01-core-models/spec.md` (203 lines) — `ContextModel` / `SourceLocation` / `RectInfo` / `WidgetFacts` / `DeveloperIntent` / `VisualChanges` stub
  - `L02-widget-resolver/spec.md` (237 lines) — `WidgetResolver` + `SourceResolver`/`BoundsExtractor`/`HierarchyExtractor`/`TextExtractor`
  - `L03-selection-engine/spec.md` (232 lines) — `SelectionEngine.selectAt` via `WidgetsBinding.hitTest` + `SelectionResult`
  - `L04-overlay-activation/spec.md` (227 lines) — `AgenationOverlay` + `AgenationController` + `SelectionHighlight` + activation toggle (stroke-only, non-obscuring)
  - `L05-info-panel/spec.md` (252 lines) — 5-section panel (Widget/Source/Geometry/Hierarchy/Runtime) with bounded tree, bottom-sheet↔side-panel
  - `L06-annotation/spec.md` (226 lines) — `AnnotationManager` + `FeedbackField` (trim + 2000 cap, per-selection reset)
  - `L07-exporter-clipboard/spec.md` (320 lines) — `MarkdownExporter` (deterministic, 7 sections, snapshot goldens) + `JsonExporter` + `ClipboardService` + `CopyButton`
  - `L08-demo-app/spec.md` (225 lines) — minimal `example/` demo (5 types, 2 routes, nested 3 deep, all 6 platforms, M3 instrument aesthetic)
- **All specs include your requested details**: Languages (Dart 3.12.2 / Flutter 3.44.9), precise classes + functions + files tables, canonical folder-structure ascii, component-tree/wireframe ascii, design notes (no purple gradient AI slop — M3 neutral instrument, Inter/JetBrains Mono, 1.5px stroke highlight), differentiation from `Widgetation`/`Pintap`/`Flan`/`DevTools`, and testing + analyze gates. `Feature_docs/README.md` indexes L00–L08.
- **No production Dart in `lib/src/`** written — only specs + toolchain (doc-only as resolved). Gaps for generated code are already ignored.

## Next Up (exact order — no large features, level-by-level working)

1. **Your approval of L00–L08 specs** — hard gate per `Agent.md` Step 6 + your "only write specs" instruction. Do not proceed to code until you approve.
2. **Reconnaissance (doc-only, per your answer)**: inspect repo (`git ls-files`, `pubspec.yaml`, `analysis_options.yaml`, `.specify/`, `Feature_docs/`), study `Widgetation`/`Pintap`/`Flan`/`DevTools`/`WidgetInspector`/`Element`/`RenderObject`/`hitTest` APIs — produce a short recon note; **do not scaffold `lib/src/` yet**.
3. **Fork-vs-Build assessment ADR-015** — table per `build-instructions.md:27-58` criteria → decision reuse/depend/adapt/fork/independent + rationale + license note; append to `context/decision.md` + root `decisions.md`; await your approval before any pipeline Dart.
4. **After both approvals** → implement levels sequentially, one per commit, each `flutter analyze` / `flutter test` gated:
   - L01 → L02 → L03 → L04 → L05 → L06 → L07 → L08 (every commit: `dart format` → `flutter analyze` → relevant tests → `git diff` inspected)
5. **Acceptance**: demo on Web + at least one desktop passes `spec.md:Acceptance Test` (multi-type + nested + source? + bounds + hierarchy + feedback + Markdown + copy + graceful unavailable) and `flutter build web` succeeds for all 6 per your "All 6 equally" answer.

## Open Questions (resolved 2026-08-28)

- Q1: Scaffold timing — **RESOLVED: Doc-only first** — recon is documentation only; no `lib/src` until after ADR-015.
- Q2: Version floor — **RESOLVED: Flutter 3.44.9 / Dart 3.12.2 latest** (pinned in `pubspec.yaml`, verified via `flutter --version`), `very_good_analysis` as preset.
- Q3: License — still open (`LICENSE` template) — assume MIT pending confirmation; needed for D-001 fork assessment.
- Q4: Lint — **RESOLVED: very_good_analysis** (strict).
- Q5: Platform priority — **RESOLVED: All 6 equally** — demo/acceptance blocks on Android, iOS, Web, Windows, macOS, Linux.
- Q6: Spec granularity — **RESOLVED: Approve proposal** — 9 small levels (L00–L08) with hybrid Specify + `Feature_docs` (your answers 2026-08-28).
- Q7: Design — **RESOLVED: Confirm instrument** — M3 neutral instrument, precision/hierarchy/control, no decoration, ascii wireframes in every spec.
- Q8: Dummy — **RESOLVED: Minimal demo** — 2-3 screen showcase with 5+ types, not a Windows 11 clone, per your answer.

*Only Q3 remains open.*

## Architecture Decisions

See `context/decision.md` Decision Index — newest: **ADR-014** (L00–L08 small-slice spec plan), **ADR-013** (align context/ with root docs), **ADR-012** (inspection tool not generator), **ADR-011** (V1 seams), **ADR-010** (Markdown primary), **ADR-009** (optional source), **ADR-008** (recon + Fork-vs-Build). Next expected: ADR-015 (Fork-vs-Build outcome after recon).

## Pre-Exit Checks (this spec commit)

- [x] `specify init` completed with `opencode` integration (`specify check` → available)
- [x] `pubspec.yaml` + `.gitignore` + `analysis_options.yaml` aligned for generated ignores; very_good_analysis 7.x pinned
- [x] `flutter pub get` + `flutter analyze` + `dart analyze` → No issues found! (verified this commit)
- [x] 9 `Feature_docs/*/spec.md` written with languages/classes/functions/files/folder ascii + instrument design (no AI slop) + differentiation
- [x] No `lib/src/` production code written — spec-only gate honored
- [x] Features are small & working-testable (one level = one focused concern, each independently describable as "working" when implemented)
- [ ] Spec approval — awaiting your explicit approval before reconnaissance + implementation

## Traceability

- Spec slice → `spec.md:FR-001–FR-014` mapped across L00→L08 (see `Feature_docs/README.md` table) — no FR missed, no V2/V3 creep.
- Pipeline → `architecture.md:15-59` → `Feature_docs/L01`..`L07` core modules in order.
- Selection → `architecture.md:87-93` hit-testing → `L03-selection-engine/spec.md`.
- Export → `spec.md:134-175` Markdown shape → `L07-exporter-clipboard/spec.md` snapshot goldens.
- Demo → `spec.md:Acceptance Test` + `build-instructions.md:Completion Criteria` → `L08-demo-app/spec.md` minimal harness.
- Design → `design-statement.md:03-15` instrument → every spec's Design section.
- Governance → `build-instructions.md` recon → ADR-015 next; `Agent.md` hard gate → spec approval required now.

