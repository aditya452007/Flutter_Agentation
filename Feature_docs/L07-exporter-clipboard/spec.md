# Feature Specification: L07 — Exporter & Clipboard

**Feature Branch**: `L07-exporter-clipboard`

**Created**: 2026-08-28

**Status**: Draft — depends on L00–L06 (needs ContextModel + intent + panel slot)

**Input**: `spec.md:FR-010/FR-011/FR-009` (generation + copy + screenshot) + `architecture.md:3.6` Context Exporter + `decisions.md:D-010` Markdown First + `architecture.md:196-198` deterministic + `spec.md:134-175` suggested output

## User Scenarios & Testing

### User Story 1 — Generate deterministic Markdown for the current selection+note (Priority: P1)

As the developer, I press **Copy Markdown** and get a stable, agent-readable document with sections **Target / Source / Geometry / Hierarchy / Runtime Details / Developer Feedback / Visual Evidence**.

**Why P1**: `spec.md:FR-010` + `decisions.md:D-010` — the Markdown is the primary deliverable; the external agent consumes it. If it's unstable or incomplete, the agent must rediscover the widget (`problem-statement.md:117-129` failure).

**Independent Test**: Construct `ContextModel` for `ElevatedButton` at `lib/screens/home.dart:143:12` with text "Get Started" + hierarchy `["Scaffold","Column","Card","ElevatedButton"]` + note "Make more rounded + taller" → `exporter.export(model)` equals a checked-in snapshot string byte-identical on repeated runs.

**Acceptance Scenarios**:
1. **Given** a full `ContextModel`, **When** `MarkdownExporter.export(model)`, **Then** output matches the snapshot (see Golden Markdown below) with correct headings and field order
2. **Given** `sourceLocation == null`, **When** exported, **Then** Source section contains `Source unavailable in this build` and no fabricated `File:` line
3. **Given** `intent == null` (no note typed), **When** exported, **Then** the `## Developer Feedback` section shows `_No feedback provided_` or is omitted (spec choice: show placeholder — consistent per snapshot)

---

### User Story 2 — One tap copies to clipboard (Priority: P1)

As the developer, I tap **Copy Markdown** → toast "Copied" → I can paste into Claude/Cursor/Copilot. No second dialog, no save file step.

**Why P1**: `spec.md:FR-011` + `design-statement.md:56-58` — the Copy CTA is the prominent primary action.

**Independent Test**: Widget test: pump `CopyButton(exporter, model)` → `tester.tap(button)` → `Clipboard.getData('text/plain')?.text == expectedMarkdown` (via mock `Clipboard` adapter) → `SnackBar` shows "Copied".

**Acceptance Scenarios**:
1. **Given** exporter has markdown, **When** tapping Copy, **Then** clipboard text equals that markdown and a toast appears for 2s
2. **Given** clipboard write fails (platform exception), **When** tapping Copy, **Then** exporter shows "Copy failed — select again" error and does not crash

---

### User Story 3 — Visual evidence is optional, not blocking (Priority: P2)

As the panel, when a screenshot is available I append "Captured screenshot available." in Visual Evidence, otherwise the export succeeds without it.

**Why P2**: `spec.md:FR-009` — screenshot subsystem must not block inspection if unavailable.

**Independent Test**: Export with `screenshotAvailable: false` → Markdown omits or shows "No screenshot captured" but remaining sections are complete; with `true` → adds the Evidence line.

**Acceptance Scenarios**:
1. **Given** no screenshot adapter, **When** exporting, **Then** output has no `Visual Evidence` crash and still contains all other sections
2. **Given** screenshot present, **When** exported, **Then** `## Visual Evidence` contains `Captured screenshot available.` (or base64 stub in V1 — see FR)

---

### Edge Cases

- Extremely long `properties` map — serialize as `- key: value` list, not expanded JSON blob, to keep Markdown readable.
- Note contains Markdown special chars (e.g., `#`, `*`, `` ` ``) — wrap note in `> blockquote` with escaping so it does not break headings.
- `hierarchy` empty (defunct element) — render `_Hierarchy unavailable_` instead of empty bullet.
- Determinism: export called twice on same model must be byte-identical — no `DateTime.now()` or non-deterministic ordering.

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide `MarkdownExporter` pure class with `String export(ContextModel model, {bool screenshotAvailable = false})` — synchronous, no widget, no `Future`, no network.
- **FR-002**: Exporter MUST produce sections in exactly this order (to keep snapshots stable): `## Target` (Widget + Runtime Type), `## Source` (File/Line/Column or unavailable), `## Geometry` (X/Y/Width/Height or unavailable), `## Hierarchy` (root→leaf tree with `└──` and `◄ selected` marker), `## Runtime Details` (Text/Key/semantics/properties if present), `## Developer Feedback` (blockquote or placeholder), `## Visual Evidence` (conditional).
- **FR-003**: Hierarchy rendering: each level indented 2 spaces more than parent, prefix `└── ` at each level (see `spec.md:156-159`), and last line has `◄ selected`. When `hierarchy.length == 0`, render `_Hierarchy unavailable_`.
- **FR-004**: Source unavailable rendering: `Source unavailable in this build` (styled as plain text in Markdown) with no `File:` line; not placeholder like `"unknown.dart"`.
- **FR-005**: Note rendering: when `model.intent?.note != null`, render as `> ${escapedNote}` blockquote, escaping markdown-breaking chars by prefixing backticks or escaping `#` etc.; when null, render `> _No feedback provided._` (so agent sees the absence).
- **FR-006**: Provide `JsonExporter` (or `ContextModel.toJson`) for future MCP — must be the **same** `ContextModel` serialization as `ContextModel.toJson()` in L01, not a second code path (`architecture.md:83-311`). Exporter may simply delegate to `model.toJson()` and `jsonEncode`.
- **FR-007**: Provide `ClipboardService` abstraction `abstract class ClipboardService { Future<void> copy(String text); }` with `SystemClipboardService` impl using `Clipboard.setData(ClipboardData(text: text))` — so widget tests can inject `FakeClipboardService`.
- **FR-008**: Provide `CopyButton` widget `({required ContextModel? model, required MarkdownExporter exporter, required ClipboardService clipboard})` — disabled when `model==null`; label "Copy Markdown" with `Icons.content_copy`; on press shows `SnackBar("Copied")` for 2s.
- **FR-009**: Exporter MUST NOT read the filesystem, network, or platform secret — pure function.

### Key Entities

- **MarkdownExporter**: pure function `model → Markdown`.
- **JsonExporter** (thin wrapper over `ContextModel.toJson`): for MCP seam, not used in V1 UI.
- **ClipboardService** + `SystemClipboardService` / `FakeClipboardService` (test).
- **CopyButton**: M3 `FilledButton.icon` presentational, disabled when no selection.

## Success Criteria

- **SC-001**: Snapshot tests: full model snapshot, source-null snapshot, bounds-null snapshot, no-intent snapshot — 4 checked-in `.md` goldens — all pass; `flutter analyze` → No issues.
- **SC-002**: `flutter test test/exporter/markdown_exporter_test.dart` passes with 6+ cases including determinism (export twice == same String).
- **SC-003**: Widget test: tap Copy → `FakeClipboardService.text == expected` → SnackBar appears.
- **SC-004**: Export time < 1ms for any model (measured via test `Stopwatch`).

## Assumptions

- Screenshot in V1 is `screenshotAvailable: bool` only — no actual image bytes are embedded in Markdown (keeps export optional and non-blocking). A later ADR may decide to embed `base64` or `RepaintBoundary` bytes.
- Note length already capped at 2000 in L06 — exporter does not re-cap; it just renders.

---

## Technical Design

### Languages & Versions

| Layer | Language | Version |
|-------|----------|---------|
| Exporter | Dart 3.12.2 (pure Dart, no `dart:io` needed) | Deterministic, no `DateTime` |
| Clipboard | Flutter 3.44.9 | `services.dart` `Clipboard` |
| Widget | Flutter 3.44.9 | `material.dart` `FilledButton.icon` |

### Folder Structure

```text
lib/
├── src/
│   ├── context/                  # L01 ContextModel
│   ├── resolver/                 # L02
│   ├── selection/                # L03
│   ├── overlay/                  # L04/L05 (InfoPanel now hosts CopyButton)
│   ├── annotation/               # L06
│   └── exporter/                 # NEW
│       ├── markdown_exporter.dart
│       ├── json_exporter.dart
│       ├── clipboard_service.dart
│       └── widgets/copy_button.dart
test/
├── exporter/
│   ├── markdown_exporter_test.dart
│   ├── json_exporter_test.dart
│   └── clipboard_service_test.dart
└── overlay/copy_button_test.dart
```

ASCII — export pipeline:

```text
 SelectionResult + DeveloperIntent
            |
            v
    ContextModel{ facts, intent, visual: null }  (L01)
            |
            +---------> MarkdownExporter.export(model)  --> String Markdown
            |                |
            |                +--> Target:  Widget: ElevatedButton (Runtime: ElevatedButton)
            |                +--> Source:  File: lib/screens/home.dart:143:12  OR "unavailable"
            |                +--> Geometry: X:32 Y:540 W:320 H:52
            |                +--> Hierarchy: Scaffold -> ... -> ElevatedButton ◄
            |                +--> Runtime: Text: Get Started, Key: ...
            |                +--> Developer Feedback: > note or placeholder
            |                +--> Visual Evidence: conditional
            |
            +---------> JsonExporter.toJson(model) -> Map<String,dynamic> (V3 seam)
            |
            v
    ClipboardService.copy(markdown)  --> SystemClipboard
            |
            v
    SnackBar "Copied" + return to panel
```

ASCII — Markdown golden shape (from `spec.md:134-175`, adapted):

```text
# Flutter UI Feedback                (title)

## Target
- Widget: ElevatedButton              (facts.widgetType)
- Runtime Type: ElevatedButton        (facts.runtimeType)

## Source
- File: lib/screens/home.dart         (or "Source unavailable in this build")
- Line: 143
- Column: 12

## Geometry
- X: 32
- Y: 540
- Width: 320
- Height: 52

## Hierarchy
Scaffold                              (facts.hierarchy[0])
└── Column                             (facts.hierarchy[1])
   └── Card                            (facts.hierarchy[2])
      └── ElevatedButton ◄ selected   (facts.hierarchy.last + marker)

## Runtime Details
- Text: Get Started                   (facts.text)
- Key: [MyKey]                        (facts.key)

## Developer Feedback
> Make this button more rounded and slightly taller.   (| intent.note as blockquote)

## Visual Evidence
Captured screenshot available.        (if screenshotAvailable)  OR omitted in V1
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/src/exporter/markdown_exporter.dart` | `class MarkdownExporter { String export(ContextModel m, {bool screenshotAvailable=false}); }` |
| `lib/src/exporter/json_exporter.dart` | `class JsonExporter { Map<String,dynamic> toJson(ContextModel m); String toJsonString(...); }` |
| `lib/src/exporter/clipboard_service.dart` | `abstract ClipboardService` + `SystemClipboardService` + `FakeClipboardService` |
| `lib/src/exporter/widgets/copy_button.dart` | `CopyButton` |
| `test/exporter/markdown_exporter_test.dart` | Snapshot + branching + determinism + escaping tests |
| `test/exporter/json_exporter_test.dart` | Delegates to `ContextModel.toJson` equality |
| `test/exporter/clipboard_service_test.dart` | Copy + error branch |
| `test/overlay/copy_button_test.dart` | Disabled when null, enabled tap → fake clipboard |

Also update `lib/src/overlay/info_panel.dart` to mount `CopyButton` in its L05 placeholder slot.

### Classes

| Class | File | Responsibility |
|-------|------|----------------|
| `MarkdownExporter` | `markdown_exporter.dart` | `String export(ContextModel, {bool screenshotAvailable})` — builds section by section with deterministic order |
| `JsonExporter` | `json_exporter.dart` | `Map<String,dynamic> toJson(ContextModel m) => m.toJson()` — seam for MCP |
| `ClipboardService` | `clipboard_service.dart` | `abstract Future<void> copy(String text)` |
| `SystemClipboardService` | `clipboard_service.dart` | `Clipboard.setData(ClipboardData(text: text))` |
| `FakeClipboardService` | `clipboard_service.dart` | `String? text; Future<void> copy(s) async => text=s;` (test helper) |
| `CopyButton` | `widgets/copy_button.dart` | `const CopyButton({model, exporter, clipboard, enabled})`; M3 `FilledButton.icon`; SnackBar on success |

### Functions / APIs

```dart
// markdown_exporter.dart
class MarkdownExporter {
  const MarkdownExporter();
  String export(ContextModel model, {bool screenshotAvailable = false});
  String _renderHierarchy(List<String> path);
  String _escapeNote(String note); // escape markdown-breaking chars
}

// json_exporter.dart
class JsonExporter {
  const JsonExporter();
  Map<String,dynamic> toJson(ContextModel model);
  String toJsonString(ContextModel model) => jsonEncode(toJson(model));
}

// clipboard_service.dart
abstract class ClipboardService { Future<void> copy(String text); }
class SystemClipboardService implements ClipboardService {
  @override Future<void> copy(String text) => Clipboard.setData(ClipboardData(text: text));
}

// widgets/copy_button.dart
class CopyButton extends StatelessWidget {
  const CopyButton({super.key, required this.model, required this.exporter, required this.clipboard});
  final ContextModel? model;
  final MarkdownExporter exporter;
  final ClipboardService clipboard;
}
```

### Design — Instrument aesthetic

- CopyButton: `FilledButton.icon` 100% width in panel, `Icons.content_copy` 18px, label "Copy Markdown" Inter 600 14px, 12 radius, primary. No floating decorative gradient — per your anti-slop rule. Toast: `SnackBar` with `surfaceContainerHigh`, short 2s.
- Markdown headings use `#` / `##` — clean, scannable, no emoji decoration.

### Differentiation

- `Widgetation`/`DevTools` expose raw diagnostics; this exporter is **curated for agents**: fixed section order, bounded hierarchy, "unavailable" explicit, note as blockquote — optimized for LLM ingestion (`decisions.md:D-010` Markdown first).

### Testing & Analyze Notes

- Run `flutter analyze` → No issues; `flutter test test/exporter/` + `flutter test test/overlay/copy_button_test.dart` → all green.
- Snapshot goldens: `test/exporter/goldens/markdown_full.md` etc. — checked in, reviewed on every change.
- No `dart:io`, no network — exporter stays pure; `analysis_options` excludes gen files.

### How to verify

```ps
flutter analyze
flutter test test/exporter/markdown_exporter_test.dart
flutter test test/overlay/copy_button_test.dart
```

### Golden Markdown example (checked in as `test/exporter/goldens/markdown_full.md`)

```markdown
# Flutter UI Feedback

## Target

- Widget: ElevatedButton
- Runtime Type: ElevatedButton

## Source

- File: lib/screens/home.dart
- Line: 143
- Column: 12

## Geometry

- X: 32
- Y: 540
- Width: 320
- Height: 52

## Hierarchy

Scaffold
└── Column
   └── Card
      └── ElevatedButton ◄ selected

## Runtime Details

- Text: Get Started
- Key: [MyKey]

## Developer Feedback

> Make this button more rounded and slightly taller.

## Visual Evidence

Captured screenshot available.
```

