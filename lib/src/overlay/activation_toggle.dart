import 'package:flutter/material.dart';

/// Compact toggle for inspection mode.
class ActivationToggle extends StatelessWidget {
  const ActivationToggle({
    super.key,
    required this.isEnabled,
    required this.onToggle,
  });

  final bool isEnabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Toggle inspection',
      button: true,
      child: FloatingActionButton.small(
        heroTag: 'agnetation_toggle',
        onPressed: onToggle,
        backgroundColor: isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHigh,
        foregroundColor: isEnabled ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
        child: Icon(isEnabled ? Icons.center_focus_strong : Icons.center_focus_weak),
      ),
    );
  }
}
