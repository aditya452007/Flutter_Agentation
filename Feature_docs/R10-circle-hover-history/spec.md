# Feature Specification: R10 — Circle Trigger, Hover Border & Minimal History

**Feature Branch**: `R10-circle-hover-history`

**Created**: 2026-08-28

**Status**: Draft — awaiting your approval (no code yet)

**Input**: Your feedback on current demo + investigation of Next.js Agentation (`agentation.com`, `benjitaylor/agentation`, `alexgorbatchev/agentation`) and Flutter inspector packages (`flutter_widget_inspector`, `ispect_layout`, `zero_inspector_kit`)

## Investigation Summary

**Next.js Agentation (original) — how it opens & locates:**

- Entry is a **circle** with logo in middle, fixed **bottom-right** (`agentation.com`: “Click the icon in the bottom-right corner to activate” — npm `agentation`: `Agentation` component renders toolbar in bottom-right). Clicking the circle **expands to a pill / toolbar** with controls: **Pause • Visibility • Copy • Clear • Send • Layout Mode • Settings** (`agentation.com/features` Toolbar controls). The toolbar is **draggable to reposition**, marker click to remove / right-click to edit.
- **Hover**: “Hover over elements to see their names highlighted” — a colored border + name badge follows cursor. Smart identification uses **CSS selectors + class names + React component tree** (`Smart identification`, `React detection` — modes: Compact/Standard/Detailed/Forensic). Computed styles are collapsible.
- **Click**: adds an **annotation marker (numbered 1,2…)** — different marker styles for single / multi-select / area (always green). Popup shows only a **text input + Add/Cancel**, not the full hierarchy/styles — those go to the **copied Markdown** (selectors, source file paths, component tree, computed styles, feedback). Output is per `agentation.com/output` + `schema` AFS 1.1.
- **History**: localStorage per-page persists 7 days, marker list in toolbar, `Clear` removes all, click marker to remove, right-click to edit. MCP sync makes it cross-page + two-way (agent can `agentation_get_all_pending`, `resolve`, `watch`).
- **Mouse differentiation**: `RenderSearch.find()` in `flutter_widget_inspector` uses **BoxHitTestResult → smallest-area RenderBox** (not deepest depth), so background (large 200×200 Container) vs button (120×60) is distinguished by area, not just depth. Next.js uses selector specificity (smallest matching selector) for the same reason. Our current `SelectionEngine.deepestByBounds` (depth-only) picks `Text` leaf (deepest) instead of `InkWell`/`ElevatedButton`, hence your “mouse cursor not properly able to select right components”.

**Flutter packages reviewed:**
- `flutter_widget_inspector` (duyhayt): **long-press to activate**, tap to inspect smallest-area `RenderBox`, red highlight border + dashed rulers, **draggable dark info panel**, blue→red badge, zero-cost disable (`enabled:false` returns child).
- `ispect_layout` / `zero_inspector_kit`: **floating button via `Overlay`**, auto-dock to edge with peek, breathing animation, `Overlay` independent of page tree, compare mode (gap measurement), color picker.
- Common Flutter pattern for hover-like on desktop/web: `MouseRegion.onHover` to show border, not just `Listener.onPointerDown` (which only fires on click). Our current overlay only does `onPointerDown` → no hover border.

## User Scenarios & Testing

### User Story 1 — Circle → Pill (Priority: P1)

As a developer I see a **small circle (40dp) with Agentation logo** in bottom-right. I click it, it morphs to a **pill** (`Agentation  • 2 • Copy • Clear`) with animated width, not a curved rectangle that blends.

**Why P1**: You reported “only a circle component with the logo in the middle as the user click it it opens in a pill format” — current pill is always visible rectangle, not circle-then-pill. Next.js does this to keep entry subtle.

**Independent Test**: Pump `DemoApp` → `find.byType(CircleToggle)` finds one `CircleAvatar` 40dp with `Icons.smart_toy`; tap → `find.text('Copy')` appears and circle is gone; tap `Close` → circle returns. Works on all 6 platforms.

**Acceptance Scenarios**:
1. **Given** app start (inspect off), **When** view loads, **Then** only circle 40dp is visible at bottom-right, not the full pill
2. **Given** circle visible, **When** tapped, **Then** pill expands (width 40→220, 220ms `easeOutCubic`) showing `Copy (n)` + `Clear` + `History` chevron, circle icon stays at left of pill
3. **Given** pill open and inspect off, **When** tap outside, **Then** pill stays (does not auto-dismiss) — only `Close` or `Esc` collapses to circle

---

### User Story 2 — Hover Border to Identify Component (Priority: P1)

As I move mouse (desktop/web) over the UI while inspect is on, the component under cursor shows a **colored border (primary 1.5px) + name badge** instantly, without clicking, so I can tell background vs Card vs Button.

**Why P1**: You reported “mouse cursor not properly able to select right components … should differentiate background/component/division/buttons properly … moving mouse will let user identify where user is” — current code only shows border *after* click (`onPointerDown`), no hover.

**Independent Test**: Enable inspect → `tester.hoverAt(centerOf(Card))` → `find.text('Card')` badge appears with border `primary`; move to `ElevatedButton` → badge updates to `ElevatedButton` without click.

**Acceptance Scenarios**:
1. **Given** inspect on and mouse over `Card` (200×200) that contains `ElevatedButton` (120×60), **When** cursor at button center, **Then** highlight is `ElevatedButton` (or its `InkWell`) not the large `Card` — verified via smallest-area rule, not deepest depth
2. **Given** inspect on, **When** cursor moves from `Card` background to `Button`, **Then** border animates (80ms) from Card rect to Button rect, badge text changes
3. **Given** `MediaQuery.disableAnimations`, **When** hovering, **Then** border jumps instantly (no animation)

---

### User Story 3 — Click Shows Only Input Box, Not Full Info (Priority: P1)

As I click a component, I see **only a small anchored popup with a text box** (“Say kind of thing” / command input) + `Add`/`Cancel`, not the full `Widget/Source/Geometry/Hierarchy/Runtime` dump. The full info is only in the **copied Markdown**.

**Why P1**: You said “when user is clicking on component does to show this much information there should be only an input text box with commands … Information will only be shown when user copies” — current `InfoPanel` shows all 5 sections immediately on click, which you find noisy.

**Independent Test**: Click `ElevatedButton` → `find.byType(InfoPanel)` finds **zero**; `find.byType(FeedbackField)` finds one popup anchored within 16px of selection rect, with `hintText: 'Say what to change…'`; `find.text('Source')` is absent until copy.

**Acceptance Scenarios**:
1. **Given** inspect on and widget selected, **When** click, **Then** only `FeedbackPopup` appears (text field + `Add` + `Cancel`), positioned near selection (flip above/below if near edge)
2. **Given** popup open and text entered, **When** `Add` tapped, **Then** a numbered marker `1` appears on the widget, popup closes, and an entry is added to history
3. **Given** no selection, **When** inspect off, **Then** no popup is mounted

---

### User Story 4 — History of Multiple Components with Delete (Priority: P1)

As I annotate multiple widgets, I see a **history list** (like Next.js marker list) inside the expanded pill / toolbar, each row shows `1 • ElevatedButton • "Make more rounded"` with a delete `✕` per row and `Clear` / `Copy all` actions. I can delete one or clear all.

**Why P1**: You said “user might not just click on single component user want multiple components so a history kind of thing … when user can delete” — current `AnnotationManager` keeps only one `current` note, no list, and `InfoPanel` placeholder is per-selection.

**Independent Test**: Annotate `Button` (“round”), then `Card` (“more padding”) → `find.text('1')` and `find.text('2')` in history list; tap delete on `1` → `find.text('1')` gone, `2` remains; `find.text('Copy (1)')` updates count.

**Acceptance Scenarios**:
1. **Given** two annotations exist, **When** history chevron in pill tapped, **Then** history sheet shows two rows: `1 ElevatedButton` + note preview + delete icon, `2 Card` + note
2. **Given** history with 2, **When** delete `1`, **Then** remaining `2` becomes `1` (re-index) and marker `1` on canvas is removed
3. **Given** history empty, **When** pill open, **Then** `Copy` is disabled and shows `Copy (0)`

---

### Edge Cases

- Circle draggable? Next.js toolbar is draggable; Flutter `flutter_widget_inspector` panel is draggable, `zero_inspector_kit` auto-docks to edge with peek. Should circle be draggable and remember position via `SharedPreferences`?
- Text selection vs element: Next.js supports **text selection** to annotate specific content; should Flutter support selecting a `Text` span vs its `Container` parent? Our `TextExtractor` shallow vs deep.
- Area selection (drag to annotate any region, even empty space) — Next.js supports, our `SelectionEngine` currently only picks `RenderBox` that contains point, not empty area.
- Animation pause: Next.js toolbar has **Pause** to freeze animations for capture — Flutter has no equivalent yet; should we add a toggle that pauses `Ticker`?
- Hierarchy filtering: current filter removes `_` private but still shows `Semantics` etc. — should we keep forensic vs standard modes (like Next.js `React detection` Compact/Standard/Detailed/Forensic)?
- Keyboard: Next.js has `Cmd+Shift+F` etc. — should pill support `Esc` to close popup/history?

## Requirements

### Functional Requirements

- **FR-001**: Entry must be a **circle 40dp** (`CircleAvatar`/`Material` circle) with logo (`Icons.smart_toy_outlined` or custom SVG) at bottom-right `Offset( -16, -16 )` from safe area, `elevation:6`, `secondaryContainer` bg. On tap, **morphs to pill** (`AnimatedContainer` 40→240 width, 220ms `easeOutCubic`) showing `Copy (n)` + `Clear` + history chevron. No curved rectangle pill by default.
- **FR-002**: **Hover** must be supported on desktop/web via `MouseRegion.onHover` (not just `Listener.onPointerDown`). While `isEnabled`, every `onHover` calls `SelectionEngine.hoverAt(offset)` which updates a **hovered** `ValueNotifier<SelectionResult?>` (distinct from `selected`) and draws a **hover border** (`primary` 1.5px, `IgnorePointer`, `AnimatedPositioned` 80ms). Click commits hovered → selected + popup.
- **FR-003**: **Smallest-area** wins: `SelectionEngine` must use `RenderSearch.smallest-area` heuristic (like `flutter_widget_inspector`) not deepest depth. Among `RenderBox`es whose rect contains offset, pick the one with **smallest area** (`width*height`) that is also relevant (not `_` private, not `RenderView`), to differentiate background (large 200×200 `Card`) vs button (120×60) vs `Text` leaf (smallest). Keep lift from `Text` leaf to `Button` ancestor as fallback.
- **FR-004**: **Click popup** must be **only** `FeedbackPopup` — a `Material` card (12dp radius, `surfaceContainerHigh`, 280×120) anchored to selection rect (flip above/below if near viewport edge via `LayoutBuilder`), containing `TextField` with hint `Say what to change…` + `Cancel` (text button) + `Add` (`FilledButton`). No `InfoPanel` hierarchy/bounds shown there.
- **FR-005**: **History** must be a list of `AnnotationEntry { id: int, facts: WidgetFacts, note: String }` stored in `AnnotationHistory` (`ValueNotifier<List<…>>`, max 50, persist to `SharedPreferences` per-page like Next.js localStorage 7d? Or in-memory only for V1). Pill shows `Copy (n)` badge count. History sheet (bottom sheet or side panel ≥900px) lists rows with `id • widgetType • note preview` + delete `Icons.close` per row + `Clear all`. `Copy` generates Markdown for **all** entries (one `## Annotation 1` per entry) via `MarkdownExporter.exportAll(List<ContextModel>)`.
- **FR-006**: Draggable: circle/pill must be **draggable** (`GestureDetector.onPanUpdate` + `Positioned`) and **auto-dock to nearest edge with peek** like `zero_inspector_kit` (only 12px peek visible when docked), tap peek to pull out. Position persisted to `SharedPreferences`.
- **FR-007**: All 6 platforms: circle/pill, hover (mouse) + tap (touch) must work; on touch devices hover is no-op, only tap selects.

### Key Entities

- **CircleToggle** (`lib/src/overlay/circle_toggle.dart`): 40dp circle, morphs to `PillToolbar` on tap.
- **PillToolbar** (`lib/src/overlay/pill_toolbar.dart`): expanded state with `Copy (n)`, `Clear`, history chevron, settings.
- **HoverEngine** (`lib/src/selection/hover_engine.dart` or `SelectionEngine.hoverAt`): `MouseRegion` → `hovered` notifier → `HoverHighlight` (translucent border, not `SelectionHighlight` solid).
- **FeedbackPopup** (`lib/src/annotation/feedback_popup.dart`): anchored card with `TextField` + `Add/Cancel`, calls `history.add(entry)` on `Add`.
- **AnnotationHistory** (`lib/src/annotation/annotation_history.dart`): `ValueNotifier<List<AnnotationEntry>>`, `add/remove/clear/reindex`, `toContextModels()`.
- **MarkdownExporter.exportAll** (`lib/src/exporter/markdown_exporter.dart`): iterates history, writes `## Annotation n` per entry.

## Success Criteria

- **SC-001**: `flutter test` — `Circle→Pill` morph test, `hover` border test (smallest-area picks button over Card), `FeedbackPopup` only-input test, `history add/delete/reindex` test — ≥8 new widget tests.
- **SC-002**: `flutter analyze` No issues, `flutter test` all green, `example` builds `web` + `windows`, manual: circle visible at bottom-right on all 6, hover shows border without click, click shows only input, history shows 2 entries with delete.
- **SC-003**: No `InfoPanel` hierarchy shown on click — hierarchy only in copied Markdown (verify `find.text('Hierarchy')` is 0 in panel test, but `find.text('Hierarchy')` is 1 in `markdown_exporter_test`).
- **SC-004**: Performance: hover updates at 60fps, no `O(N^2)` walk on every mouse move — `RenderSearch` caches or debounces 16ms.

## Assumptions

- Next.js Agentation's circle→pill timing (220ms `easeOutCubic`) is a reasonable default for Flutter; you may want a different easing.
- Hover is desktop/web only; touch devices keep current tap-to-select.
- History is in-memory for V1 (not yet `SharedPreferences` persisted 7 days like Next.js) — persistence can be L10.
- Text selection vs element vs area vs multi-select vs animation pause are **out of scope for this spec** (Next.js supports them, but you asked to focus on circle/pill, hover, minimal popup, history first). They can be R11.

---

## Open Questions — Need Your Answers Before Coding

1. **Circle asset**: Use `Icons.smart_toy_outlined` as logo, or do you have a custom SVG/logo for Agentation circle? Should circle have a number badge when history non-empty (like Next.js marker count)?
2. **Pill contents**: When expanded, should pill show exactly `Copy (n) • Clear • History` + `Settings` cog, or also `Pause` (freeze animations) and `Visibility` (toggle markers) like Next.js toolbar?
3. **Draggable + peek**: Should circle be draggable + auto-dock with 12px peek (like `zero_inspector_kit`), or fixed bottom-right only?
4. **Hover color**: Primary `1.5px` border is proposed — should hover be a different color/alpha than selected (e.g., hover `primary` 30% dashed, selected `primary` solid), and should hover also show a small badge with widget name (like Next.js “Hover over elements to see their names”)?
5. **Selection heuristic**: Smallest-area `RenderBox` vs deepest depth — you reported background vs button confusion, which smallest-area solves. Should we also filter to hide `_` private widgets before area compare, or keep them for forensic mode?
6. **Popup placement**: Feedback popup is 280×120 anchored to selection rect, flips above if near bottom edge — is that the right size/placement, or should it be centered like Next.js modal?
7. **History persistence**: In-memory only for V1, or `SharedPreferences` per-page 7d like Next.js? Should `Copy` also clear after copy (Next.js has `Clear on copy` setting)?

**Do not start coding until you confirm the spec and answer the 7 questions — reply with “Proceed” and your choices, and I will implement R10 in small commits (Circle→Pill, Hover, Popup, History) with `flutter analyze` gates.**

Related files to change (when approved): `lib/src/overlay/activation_toggle.dart` → split into `circle_toggle.dart` + `pill_toolbar.dart`, `lib/src/selection/selection_engine.dart` (smallest-area + hover), `lib/src/annotation/annotation_history.dart` (new), `lib/src/annotation/feedback_popup.dart` (new), `lib/src/exporter/markdown_exporter.dart` (`exportAll`), `example/lib/main.dart` (unchanged wrapper).

