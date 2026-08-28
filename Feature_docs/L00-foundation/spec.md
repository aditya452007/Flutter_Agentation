# Feature Specification: L00 — Foundation & Toolchain

**Feature Branch**: `L00-foundation`

**Created**: 2026-08-28

**Status**: Draft — awaiting approval (no Dart feature code in this level, only toolchain)

**Input**: Build from `build-instructions.md` Mandatory First Phase + `context/architecture.md` Invariants + user request "use latest flutter/dart, use Specify CLI, use .gitignore to ignore generated files, run flutter analyze"

## User Scenarios & Testing

### User Story 1 — Clean checkout builds and analyzes (Priority: P1)

A new contributor clones the repo, runs `flutter pub get` + `flutter analyze`, and sees **No issues found** without needing to delete generated artifacts.

**Why this priority**: Every later level depends on a green toolchain. If analyze is red on day 0, every subsequent `lib/src/` change is suspect.

**Independent Test**: Clone fresh → `flutter pub get` → `flutter analyze` → passes. `dart analyze` also passes. Can be tested without any `lib/src/` feature code.

**Acceptance Scenarios**:
1. **Given** a fresh clone without `build/` or `.dart_tool/`, **When** `flutter pub get && flutter analyze`, **Then** output is `No issues found!`
2. **Given** a generated file exists (`*.freezed.dart`), **When** `flutter analyze`, **Then** it is excluded and does not produce warnings

---

### User Story 2 — Specify workflow is usable (Priority: P2)

A developer can run `/speckit.specify`, `/speckit.plan`, etc. via the `specify` CLI and `opencode` integration.

**Why this priority**: Your instruction requires Specify CLI skill for all specs — toolchain must expose it.

**Independent Test**: `specify check` shows `opencode available`; `.specify/` templates exist; `.specify/memory/constitution.md` exists.

**Acceptance Scenarios**:
1. **Given** repo root, **When** `specify check`, **Then** `opencode available` is reported
2. **Given** `.specify/templates/spec-template.md` exists, **When** creating a new feature via `create-new-feature.ps1`, **Then** it scaffolds correctly

---

### Edge Cases

- Developer on Windows vs macOS — `pub get` and analyze must work identically (platform-neutral Dart).
- Very old Flutter SDK (<3.44) — `pubspec.yaml` environment constraint `>=3.44.9` fails clearly with a readable SDK message, not silent breakage.
- `very_good_analysis` 7.x vs 10.x — pinned to `^7.0.0` to avoid surprise breaking lint rules; upgrade is an ADR.

## Requirements

### Functional Requirements

- **FR-001**: Repo MUST declare Flutter **3.44.9** stable + Dart **3.12.2** as the baseline (`flutter --version` at spec time). Toolchain MUST be verified with `flutter --version` and `dart --version`.
- **FR-002**: `pubspec.yaml` MUST pin `sdk: ">=3.12.2 <4.0.0"` and `flutter: ">=3.44.9"` and declare `very_good_analysis ^7.0.0` + `flutter_lints ^5.0.0` as dev dependencies (no other deps in L00).
- **FR-003**: `analysis_options.yaml` MUST `include: package:very_good_analysis/analysis_options.yaml`, enable `strict-casts/inference/raw-types`, and `exclude` all generated file patterns (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`, `*.gen.dart`, `l10n/generated/**`, `build/**`, `.dart_tool/**`, `.specify/**`) so analyze stays green.
- **FR-004**: `.gitignore` MUST ignore Dart/Flutter generated artifacts: `.dart_tool/`, `build/`, `*.freezed.dart`, `*.g.dart`, `*.gr.dart`, coverage, plus OS files. See `.gitignore:2-22`.
- **FR-005**: `analysis_options.yaml` and `.gitignore` MUST be consistent — every pattern excluded from analysis is also gitignored, so generated drift never becomes a commit.
- **FR-006**: `.specify/` MUST be initialized (`specify init --here --integration opencode`) with `ps` scripts and `spec-template.md`/`plan-template.md`/`tasks-template.md` available.
- **FR-007**: `Feature_docs/README.md` MUST index all V1 levels (L00–L08) with dependencies.
- **FR-008**: `flutter pub get && flutter analyze` MUST pass on a clean checkout with **No issues found**.

### Key Entities

- **Toolchain Config**: `pubspec.yaml` (SDK + deps), `analysis_options.yaml` (lint), `.gitignore` (artifact hygiene). No Dart domain entities in this level.
- **Specify Project**: `.specify/` folder, `memory/constitution.md`, `templates/*`, `scripts/powershell/*`.

## Success Criteria

- **SC-001**: `flutter analyze` → `No issues found!` in <1s on CI and local (measured).
- **SC-002**: `flutter pub get` succeeds with 0 `flutter pub outdated` breakages against the pinned SDK floor.
- **SC-003**: A newly created `lib/foo.freezed.dart` is both gitignored and analyzer-excluded (verified by `git status` + `flutter analyze`).
- **SC-004**: `specify check` reports `opencode available` and `.specify/templates/spec-template.md` exists.

## Assumptions

- Flutter SDK is installed at `C:\src\flutter` (Windows) — path may differ on CI but SDK version is pinned.
- `very_good_analysis ^7.0.0` is the strict preset; upgrading to `^10.x` is deferred to avoid lint churn during V1.
- No `lib/src/` Dart code exists yet — this level is intentionally tiny (toolchain only), per "make features as small as possible and ensure they are working."

---

## Technical Design (added per your request)

### Languages & Versions

| Layer | Language | Version | Why |
|-------|----------|---------|-----|
| App/tool | Dart | **3.12.2** | Latest stable at spec time (`dart --version`); null safety + records/patterns |
| Framework | Flutter | **3.44.9** stable | Latest channel stable at spec time (`flutter --version`) |
| Config | YAML / Markdown | — | `pubspec.yaml`, `analysis_options.yaml`, specs |
| Scripts | PowerShell | — | `.specify/scripts/powershell/*` via `specify --script ps` |

### Folder Structure (this level)

```text
Flutter_Agentation/
├── pubspec.yaml                 # SDK + very_good_analysis + flutter_test
├── analysis_options.yaml        # includes very_good_analysis, excludes generated
├── .gitignore                   # ignores .dart_tool/build/*.freezed/*.g.dart
├── .specify/                    # Spec Kit (opencode integration, templates, scripts)
│   ├── memory/constitution.md
│   ├── templates/spec-template.md
│   └── scripts/powershell/
├── Feature_docs/
│   ├── README.md                # index L00–L08
│   └── L00-foundation/spec.md   # this file
├── context/                     # living docs (already synced)
└── (lib/src/ NOT yet — created incrementally L01+)
```

ASCII — docs vs toolchain:

```text
+----------------+     +-------------------+     +----------------+
| .specify/      |---->| Feature_docs/     |---->| context/       |
| templates+     |     | L00 spec (here)   |     | project-       |
| scripts        |     | L01..L08 specs    |     | overview etc.  |
+----------------+     +-------------------+     +----------------+
         |                       |
         v                       v
  specify check            flutter analyze
  /speckit.specify         flutter pub get
```

### Files to Create / Touch

| File | Action | Purpose |
|------|--------|---------|
| `pubspec.yaml` | CREATE/VERIFY | SDK + dev deps (`very_good_analysis`, `flutter_lints`, `flutter_test`) |
| `analysis_options.yaml` | CREATE | `include: very_good_analysis`, strict, exclude generated |
| `.gitignore` | EDIT | Add Flutter/Dart ignores + generated + `.specify/memory/*.md` exception |
| `.specify/**/*` | CREATED by `specify init` | Templates + scripts + constitution |
| `Feature_docs/README.md` | CREATE | Index of V1 levels |
| `Feature_docs/L00-foundation/spec.md` | CREATE | This spec |

No `lib/` files in this level.

### Classes / Functions

No Dart classes or functions in this level — toolchain only. From L01 onward, each spec will list classes/functions explicitly (e.g., `ContextModel`, `WidgetResolver.resolve()`).

### Design — Instrument, not AI slop

- Toolchain has no UI — this principle applies to later overlay specs: Material 3 neutrals, typography Inter/JetBrains Mono, no purple gradients/mesh — per `design-statement.md:03-15`.

### Differentiation from existing tools

- `Widgetation`/`Pintap`/`Flan` all assume an existing lint/setup — none standardize on `very_good_analysis` strictly. This foundation enforces **strict analysis on every commit** before any inspection code, preventing drift that those projects tolerate.

### Testing & Analyze Notes

- Run: `flutter pub get` → `flutter analyze` (must be `No issues found!`) → `dart analyze` → `specify check`.
- `.gitignore` and `analysis_options.yaml:analyzer.exclude` must stay in sync — checked manually during review.
- No `flutter test` yet — `test/` arrives at L02+.

### How to verify this feature is working

```ps
flutter --version  # expect Flutter 3.44.9, Dart 3.12.2
flutter pub get
flutter analyze    # expect "No issues found!"
specify check      # expect "opencode available"
git status         # *.freezed.dart etc. are ignored
```

