# Example — Agentation Demo

Minimal demo that validates V1 Inspect Mode across widget types.

## Run

```sh
flutter pub get
flutter run -d chrome        # Web — instant preview
flutter run -d android       # Android
flutter run -d windows       # Windows
flutter run -d macos         # macOS
flutter run -d linux         # Linux
# iOS requires macOS host
```

## Use

1. Tap the floating Inspect toggle (bottom-right) to enable inspection.
2. Tap any widget — Card, Button, ListTile, Switch, Checkbox, TextField.
3. The InfoPanel (via overlay) shows widgetType, source (if available), bounds, hierarchy, runtime details.
4. Type in FeedbackField.
5. Press **Copy Markdown** → paste into your external AI agent (Claude / Cursor / Codex).

## How it validates

- **Multi-type**: ElevatedButton, Card, ListTile, Switch, Checkbox, TextField, Divider all present.
- **Nested**: Scaffold → Column → Card → ElevatedButton = 4 deep hierarchy.
- **Two routes**: `/` and `/details` — selection works after navigation.
- **All 6 platforms**: no `Platform.is*` branching, same `AgentationOverlay.wrap` entry.

## Analyze

```sh
flutter analyze # in root and in example/
dart analyze
```
