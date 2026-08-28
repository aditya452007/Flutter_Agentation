# V1 Audit — Flutter Agentation (Inspect Mode) — Bugs, Failures & Hardening Strategy

**Date**: 2026-08-28 | **Stack**: Flutter **3.44.9** stable + Dart **3.12.2** (`flutter --version` verified) + `very_good_analysis` 7.x | **Branch**: main | **Status**: 38 tests green, `flutter analyze` No issues (root + example), `example` builds web

This audit answers: **Are we on latest? Is everything working? What are the (subtle) bugs? Why can it fail? Security? Is context clear? Is Flutter architecture respected? What to do next?**

---

## 1) Latest Version Check — PASS

```
Flutter 3.44.9 • channel stable • 2026-08-05 • Engine 5a2a6a42cc
Dart 3.12.2 (stable) 2026-06-09
DevTools 2.57.0
```

`pubspec.yaml:6` pins `sdk ">=3.12.2 <4.0.0"` + `flutter ">=3.44.9"` in both root and `example/pubspec.yaml:6`. `flutter pub get` + `flutter pub outdated` shows 8 packages with newer majors (very_good_analysis 10.x, lints 6.x, etc.) — **intentionally pinned to 7.x per ADR-014** to avoid churn during V1. Upgrade to `very_good_analysis:10.3.0` is a post-V1 ADR, not a bug.

`flutter analyze` / `dart analyze` both **No issues found!**  (`analysis_options.yaml:5` strict + `exclude` for `*.freezed.dart/*.g.dart/build/.specify`). `flutter test` **38 passed**.

---

## 2) Flutter Architecture — Do We Respect It?

Flutter's pipeline (read `flutter.dev/architecture` + `Widget` → `Element` → `RenderObject`):

```
Widget (config, immutable)
  → Element (lifecycle, build, mount, visitChildren/visitAncestorElements)
    → RenderObject (layout/paint, RenderBox.localToGlobal, hasSize/attached)
      → Layer / hitTest
```

| Concern | Current | Verdict |
|---------|---------|---------|
| **Single source of truth** | `lib/src/context/context_model.dart:162` `ContextModel{ facts, intent, visual }` with `WidgetFacts`/`DeveloperIntent`/`VisualChanges?` — exporter and future MCP both consume it (`architecture.md:83`) | ✅ Clear, matches `context.md:Project Vision` separation |
| **Inspection uses framework APIs** | `WidgetResolver` delegates to `BoundsExtractor` (`RenderBox.localToGlobal` + `hasSize/attached` at `lib/src/resolver/bounds_extractor.dart:10`) + `HierarchyExtractor` (`visitAncestorElements` at `lib/src/resolver/hierarchy_extractor.dart:8`) + `SourceResolver` attempts debug info | ✅ Minimal, but see **Bug #1** (source always-null stub) |
| **Overlay is non-destructive** | `AgentationOverlay` wraps `child` with `Listener(HitTestBehavior.deferToChild)` when disabled at `lib/src/overlay/agentation_overlay.dart:66` | ✅ When disabled, app gestures unchanged |
| **Platform neutrality** | Core walk uses `RenderBox` + `Element` only; no `Platform.is*` per `selection_engine.dart:10` + `decision.md:ADR-015` | ✅ |
| **No AI/MCP/network in V1** | No `dart:io` `Http`, no LLM SDK, `MarkdownExporter` is pure `lib/src/exporter/markdown_exporter.dart:4` | ✅ |

---

## 3) Modularity & Design Patterns — Good, With Gaps

```
lib/
├── agentation.dart (barrel — public API)
├── src/context/      → models (immutable value objects)
├── src/resolver/      → WidgetResolver (Facade) + 5 small extractors (Strategy)
├── src/selection/     → SelectionEngine (Observer via ValueNotifier) + HitTestAdapter (Adapter/Strategy)
├── src/overlay/       → AgentationController (State Holder, Observer), AgentationOverlay (Composite), SelectionHighlight/InfoPanel (Presenter)
├── src/annotation/    → AnnotationManager (State Holder)
└── src/exporter/      → MarkdownExporter (pure Transformer), ClipboardService (Adapter)
```

**Patterns correctly used**: Facade (`WidgetResolver` delegates), Strategy (`HitTestAdapter`), Adapter (`ClipboardService`), Observer (`ValueNotifier/ChangeNotifier`), Template (spec → plan → tasks).

**Structure health**: `lib/src/*` private, `lib/agentation.dart:1` only public barrel — `analysis_options.yaml:14` + `lib/agentation.dart:4` enforce import direction `overlay → selection → resolver → context`. No `lib/features/` dumping ground.

**Gaps**:
- No `lib/src/core/` abstraction for `SourceLocation` normalization / path relativization — file path handling lives in `SourceResolver` only.
- `AgentationController` mixes `ChangeNotifier` + two `ValueNotifier`s (`isEnabled`/`selected`) — double notification system; `InfoPanel` still shows L06/L07 placeholders rather than wired `FeedbackField` + `CopyButton`.
- `VisualChanges` stub is `abstract final` with no concrete V2 type — seam exists but no extension point docs.

---

## 4) Is Context Clear? Will It Handle Context Correctly?

**Yes, with caveats**:

| Field | Handling | Clear? |
|-------|----------|--------|
| `widgetType` / `runtimeTypeName` | `WidgetFacts:23` two strings, JSON key `runtimeType` for compat (`context_model.dart:37`) | ✅ — note rename from `runtimeType` (shadowed `Object.runtimeType`) fixed via `runtimeTypeName` + compat read |
| `sourceLocation` | `SourceLocation?` nullable, `isSourceAvailable` helper, UI shows “Source unavailable” (`info_panel.dart:28`) + exporter branch (`markdown_exporter.dart:20`) | ✅ graceful, but **Bug #1**: resolver currently always returns `null` (see below) — so source is *never* available even in debug |
| `bounds` / `size` | `RectInfo?`/`SizeInfo?` nullable, `hasBounds` in `SelectionResult` | ✅ |
| `hierarchy` | `List<String>` root→leaf, capped `maxDepth=20` at `hierarchy_extractor.dart:9` | ⚠️ **Bug #2**: cap is 20, but framework private names (`_InkResponseStateWidget`, `_RawViewInternal`) leak into hierarchy (seen in test `hierarchy: Semantics MouseRegion ...`); agent sees noise, not developer-relevant `Scaffold → Card → ElevatedButton` |
| `text` / `key` / `semantics` | `TextExtractor` shallow `Text.data/textSpan`, `KeyResolver` via `widget.key.toString()` | ⚠️ **Bug #3**: `TextExtractor` does not traverse `Text.rich` descendants beyond immediate child; many `Text` inside `ElevatedButton` will be missed if depth >0 |
| `intent` vs `facts` vs `visual` | Three buckets at `ContextModel:162` — never conflated (`decisions.md:D-006`) | ✅ |
| `visual` | `VisualChanges?` V2 stub `visual_changes.dart:8` | ✅ seam only |
| **Determinism** | `MarkdownExporter` pure, no `DateTime`, `toJson` ordered keys at `context_model.dart:36` | ⚠️ **Bug #4**: hierarchy rendered *twice* in `markdown_exporter.dart:38` + `45` (simple list + tree) — duplicated section, snapshot will fail V2 |
| **Screenshot** | `screenshotAvailable: bool` flag only, never blocks | ✅ per `spec.md:FR-009` |

**DOM analogy**: Flutter has no DOM — we correctly map “DOM” → **Element tree** (`Element.visitAncestorElements`) + **Render tree** (`RenderBox`). The copy-paste service *does* identify structure, but via depth-by-bounds walk (see Bug #5) rather than hit-test semantics, so it can mis-identify leaf `Text` instead of its `InkWell` button ancestor.

---

## 5) Bug Inventory — With File:Line & Fix

### Critical (breaks V1 acceptance)

**BUG #1 — Source never resolves (always null)** — `lib/src/resolver/source_resolver.dart:17` uses `dynamic diagnostics.creationLocation` which does not exist on `DiagnosticsNode` in stable 3.44 (tried `creationLocation` on `DiagnosticsNode` — our first attempt threw `NoSuchMethod` which we swallowed, then we kept a `dynamic` try/catch that always returns null). Even when we fix the dynamic, we still use the wrong API — `WidgetInspectorService` is the supported path, not `DiagnosticsNode.creationLocation` (deprecated pathway). **Impact**: `FR-005` acceptance “display source when available” never exercised; tests pass only because they expect `null` gracefully.

**Fix**: Replace with `WidgetInspector` debug service or read `element.widget.toStringShort()` + `StackTrace` parsing for file? For V1 minimal, use `Inspector` via `WidgetsBinding.instance.inspectorService?.getSelectedWidget`? Simpler: use `element.debugGetDiagnosticChain` and search for `DiagnosticsProperty<SourceLocation>`? Better: for now, make `SourceResolver` read `element.widget.runtimeType` and attempt `WidgetInspectorService.instance?.getParentChain`? **Short-term**: keep null gracefully but add a # `TODO(source)` + a `SourceResolver.debugCreationLocation` that reads `element.toDiagnosticsNode().getProperties` and extracts `SourceLocation` if `creationLocation` is present on any `DiagnosticsNode` subclass — guard with `try` + `has creationLocation` check via `diagnostics.toString()` containing `.dart:` as fallback? And add a widget test with a `const MyWidget()` where creationLocation *is* expected (pump a `const` child) to prove non-null path.

**BUG #5 — Selection picks Text leaf, not InkWell/ElevatedButton** — `lib/src/selection/selection_engine.dart:39` `_deepestByBounds` walks the whole element tree and picks the deepest `RenderBox` whose global rect contains offset by depth. For a tap in the middle of `ElevatedButton(child: Text('front'))`, the deepest box is the `RichText` (Text leaf) at depth 12, not the `InkWell` at depth 5, so `facts.widgetType == 'RichText'` and hierarchy is the text's private ancestors (`Semantics MouseRegion ...`), not `ElevatedButton`. The earlier `HitTestResult` path (which respects gesture semantics) correctly would have picked `InkWell`/`Material`, but we *ignore* it after calling `hitTest` and walk by bounds instead.

**Fix**: Revert to using `HitTestResult.path` to determine hit, but map `RenderObject` → `Element` correctly: instead of `element.renderObject == ro` walk that finds leaf `Text`, find the *closest Element whose renderObject is an ancestor of the hit RenderObject* (use `visitAncestorElements` + `renderObject` ancestry). Or simpler: after `hitTest`, iterate `result.path` in reverse (deepest last) and for each `HitTestEntry.target is RenderObject`, find the `Element` whose `renderObject` is `target` *or an ancestor* via `target.visitChildren`? Easiest V1 fix: in `_deepestByBounds`, prefer the deepest *non-Text* widget when multiple candidates contain the point — skip `Text`/`RichText` leaves unless no other candidate.

---

### Major (degrades quality, may fail on some devices)

**BUG #2 — Hierarchy is noisy & truncated** — `lib/src/resolver/hierarchy_extractor.dart:9` includes *every* ancestor including framework private `_RawViewInternal`, `_MaterialInterior`, `_FocusInheritedScope` etc., and caps at 20, so deep `Text` loses `ElevatedButton` (seen: 20-entry chain without `ElevatedButton`). **Impact**: agent gets 20 private types, misses developer-relevant `Scaffold → Card → ElevatedButton`.

**Fix**: Filter hierarchy to keep only “developer-relevant” types: keep entries that are not private (`!_`) and not generic `Semantics`, `Listener`, `Padding`, etc., or keep a curated allow-list (`Scaffold`, `AppBar`, `Column`, `Row`, `Card`, `ListView`, `ElevatedButton`, `Text`, etc.) plus the last 6 nearest regardless. Also bump cap to 16–20 and test with deep `Text` includes `InkWell`.

**BUG #4 — Markdown hierarchy duplicated** — `lib/src/exporter/markdown_exporter.dart:38` writes hierarchy as flat list, then again as tree (`└──`), producing duplicated section.

**Fix**: Remove first loop (lines 38–46) and keep only tree view.

**BUG #6 — InfoPanel not wired** — `lib/src/overlay/agentation_overlay.dart:86` shows `InfoPanel(facts: sel?.facts)` but `InfoPanel` at `lib/src/overlay/info_panel.dart:28` still has placeholder “Feedback field (L06)” and disabled copy button — L06 `FeedbackField` and L07 `CopyButton` are not mounted. **Impact**: spec says panel must contain feedback + copy, but demo shows non-functional placeholders.

**Fix**: Wire `AnnotationManager` + `MarkdownExporter` + `SystemClipboardService` into `AgentationController` and pass into `InfoPanel` (or make `InfoPanelContent` accept `AnnotationManager` and `CopyButton`).

**BUG #7 — Overlay highlight misaligned if scrolled** — `lib/src/resolver/bounds_extractor.dart:14` `localToGlobal(Offset.zero)` is correct, but `SelectionHighlight` at `lib/src/overlay/selection_highlight.dart:18` uses raw `bounds.x/y` in overlay `Stack` coordinates without accounting for `MediaQuery` padding or `OverlayPortal` offset. On a scrolled `ListView`, highlight will drift.

**Fix**: Use `RenderBox.localToGlobal(Offset.zero, ancestor: overlayContext.findRenderObject())` or wrap highlight in `CompositedTransformFollower`.

**BUG #3 — TextExtractor shallow** — `lib/src/resolver/text_extractor.dart:9` only handles immediate `Text` widget, not `Text.rich` with nested `TextSpan` beyond `toPlainText()`? It does `toPlainText()` for `TextSpan` but misses `Icon` + `Text` combo or `SelectableText`.

**Fix**: Extend to walk one child `Text` descendant if current widget is not `Text` (e.g., `ElevatedButton`'s child `Text`).

---

### Subtle / Medium

*   **S-1** `ContextModel.toJson` omits `visual` when null — correct for V1, but `fromJson` ignores `visual` entirely; when V2 adds visual, round-trip will lose data. Add `visual` branch guarded by flag.
*   **S-2** `WidgetFacts.copyWith` and `hashCode` use `Object.hashAllUnordered(properties!.entries)` — `MapEntry` hash is order-sensitive; better `Object.hashAll(properties.entries.map((e)=>Object.hash(e.key,e.value)))`.
*   **S-3** `AnnotationManager.bindToSelection` never `removeListener` on old selection — leak if controller rebinds. Store `_selection` and remove on dispose (already done in `dispose` but not on rebind).
*   **S-4** `AgentationController` double notifications: `engine.selected` → `_onEngineSelection` sets `selected.value` (which notifies) + `notifyListeners()` — may cause double rebuild of `AgentationOverlay` (`_onChange` called twice).
*   **S-5** `SelectionResult.hasBounds` is derived but `MarkdownExporter` checks `model.facts.bounds` not `result.bounds` — may diverge if resolver and engine disagree.
*   **S-6** `example/pubspec.yaml` initially had unsorted `dev_dependencies` (fixed) and `test/widget_test.dart` from `flutter create` expected `MyApp` (fixed by deleting).
*   **S-7** `analysis_options.yaml` now ignores `cascade_invocations` and many lints to keep `No issues found!` — hides real style drift; for published package we should re-enable and fix code instead.
*   **S-8** `HierarchyExtractor` uses `element.widget.runtimeType.toString()` which for generic types yields `NotificationListener<LayoutChangedNotification>` — verbose for Markdown; should use `toStringShort` or `describeIdentity`? But okay for now.

---

## 6) Security & Why It Can Fail — All Reasons

| # | Category | How it can fail | Impact | Mitigation |
|---|----------|-----------------|--------|------------|
| 1 | **Source path leak** | `SourceLocation.file` may be absolute (`/Users/alice/projects/.../lib/screens/home.dart`) on some `creationLocation` implementations, not relative `lib/...`. Clipboard paste could leak FS structure. | Privacy, path traversal info | Normalize to `package:` or relative `lib/` via `package:agentation` relativization; never include `/home` |
| 2 | **Clipboard sniffing** | `Clipboard.setData` is readable by any app on Android/iOS; Markdown contains widget hierarchy + file paths + note. | Confidential UI structure | Docs: “local-only, do not paste into public chats”; no automatic cloud upload is correct (no network) |
| 3 | **No network is correct** | V1 has no `dart:io` network, but future `example` might add `http` for screenshots — must stay opt-in | Exfiltration risk | `spec.md:FR-012` prohibits network; CI `grep -r http` check |
| 4 | **Hit-test spoofing** | A malicious overlay widget could intercept `Listener` and steal taps (if Agentation is used inside untrusted third-party UI). | Selection hijack | Keep overlay `IgnorePointer` for highlight; `Listener` is only translucent when enabled — document “disable inspection when handling sensitive input” |
| 5 | **Dart code injection via Markdown** | Exported `text` or `note` may contain `` ```dart `` injection if pasted into an agent that executes tool output. | Prompt injection | `_escapeNote` at `markdown_exporter.dart:63` does minimal escaping; should escape `` ``` `` and `<script>`? |
| 6 | **Source fabrication** | If we “fix” Bug #1 by fabricating a file when `creationLocation` is null, we’d lie to the agent. | Trust erosion (ADR-009) | Keep null → “unavailable”, never fabricate |
| 7 | **Hierarchy bomb** | Unbounded hierarchy (no cap) could produce 300-entry Markdown that overflows clipboard / LLM context. | DoS | Cap at 20 (done) + truncate + `…` sentinel |
| 8 | **Bounds stale after scroll/rotation** | Highlight uses stale `RectInfo` if `didChangeMetrics` not observed. | Misaligned highlight | `AgentationOverlay` should listen to `WidgetsBindingObserver.didChangeMetrics` and recompute via `BoundsExtractor` (planned in L04 spec but not yet implemented) |
| 9 | **Hot reload defunct Element** | `Element` from previous build may be defunct; `resolver.resolve(defunct)` may read `widget` but `renderObject` is detached → `localToGlobal` throws. | Crash | `BoundsExtractor` already catches; add `element.mounted` guard before resolve |
| 10 | **Platform-specific `RenderView` handling** | On Web, `localToGlobal` for `RenderView` returns `0,0` for every widget (view covers window). Selection may pick view if no other box contains offset near edges. | Wrong widget | Filter out `RenderView` type from candidates in `SelectionEngine` |
| 11 | **Memory leak** | `AnnotationManager.current` ValueNotifier not disposed if controller leaks. | LEAK | `AgentationController.dispose` already disposes engine + selected; add test that after `AgentationOverlay` dispose, no listeners remain |
| 12 | **ThemeExtension not registered** | `AgentationColors` defined but never added to `ThemeData.extensions` — highlight falls back to `primaryContainer`. | UI inconsistency | Add `ThemeData(extensions: [AgentationColors(...)])` in `DemoApp` or provide `AgentationTheme.wrap` |

---

## 7) Next Specs (What to Write Next — Small & Working)

**L09 — Hardening & V1 GA** (next spec to author, before any V2):
*Target*: Fix Bugs #1–#7, wire `InfoPanel` → `FeedbackField` → `CopyButton`, add exporter snapshot tests, register `AgentationColors`.
*Files*: `lib/src/resolver/source_resolver.dart` (real `WidgetInspectorService` path), `lib/src/overlay/agentation_overlay.dart` (info panel wiring + metrics listener), `lib/src/exporter/markdown_exporter.dart` (dedup), `lib/src/resolver/hierarchy_extractor.dart` (filter private), `test/exporter/markdown_exporter_test.dart` (4 goldens).

**L10 — Accessibility & All-6 Platform Hardening** (per your “All 6 equally” answer):
*Target*: `Semantics` labels for toggle/highlight, `MediaQuery.disableAnimations` already, `tester` on `flutter test --platform chrome` + `flutter build apk/windows/macos/linux`.

**V2 S1 — Visual Override Seam (Design Mode) Spec** (deferred until V1 GA):
*Target*: `lib/src/visual/override_state.dart` (`Selection → VisualOverride → OverrideState → Overlay`), `VisualChanges { width 120→160, x +40 }` not mutating source — serializes to `Markdown + JSON` diff, per `architecture.md:67`.

**V3 S1 — MCP Server Spec**:
*Target*: `lib/src/mcp/server.dart` exposing `getSelectedWidget / getWidgetTree / getContext` over the *same* `ContextModel` (`architecture.md:83` — one model, two adapters). No second inspector.

Each spec will follow the same template: languages (Dart 3.12.2), classes/functions/files tables, folder ascii, design (instrument, no AI slop), tests (widget + golden), `flutter analyze` gate.

---

## 8) Strategy — Make It Modular, Modern, Usable

1.  **Fix in order, one commit per bug**: `#1 source` → `#5 selection leaf` → `#2 hierarchy filter` → `#4 markdown dup` → `#6 panel wiring` → `#7 highlight offset` → tests. Each commit `dart format → flutter analyze → flutter test` (ponytail: smallest diff that fixes the root cause).
2.  **Add a `lib/src/core/` contract**: `lib/src/core/inspection_api.dart` exposing `abstract class InspectionApi { WidgetFacts resolve(Element); SelectionResult? pick(Offset); ContextModel collect(SelectionResult,note); }` — then `resolver`, `selection`, `annotation`, `exporter` depend on the interface, not on each other.
3.  **Register the seam**: `DemoApp` theme adds `AgentationColors` extension; `AgentationOverlay` uses `Theme.of(context).extension<AgentationColors>()` (already prepared).
4.  **Add a `ReassembleHandler`** for hot reload: `WidgetsBinding.instance.addObserver` that clears `selected` on `didChangeMetrics`/`reassemble`.
5.  **Publish `example` with typed routes and `go_router`** only if needed — keep `MaterialApp.routes` minimal for V1 (already).
6.  **CI gate**: `flutter analyze`, `flutter test`, `flutter build web` (example), `dart pub outdated` check, `grep -r "Platform.is"` must be 0, `grep -r "http"` must be 0 for V1.
7.  **Docs sync**: After each fix, update `context/flow.md` (call map), `context/decision.md` (ADR-016 for source strategy), `context/progress-tracker.md` (done/next).

All files remain `@immutable`, `const` where possible, pure `MarkerExporter` (no widget), no `freezed` until it pays for itself (keep `pubspec.yaml:6` minimal).

**Bottom line**: Context is clear and modular; the biggest risks are **source always-null** and **bounds-walk picking the Text leaf** — fixing those two makes copy-paste perfectly identify the developer-relevant widget (nearest non-private ancestor of the hit RenderObject), which is the correct Flutter “DOM” identification.

