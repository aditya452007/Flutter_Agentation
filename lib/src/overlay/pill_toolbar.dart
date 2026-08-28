import 'package:flutter/material.dart';

/// Expanded pill toolbar — full Next.js-like controls: Copy, Clear, Pause, Visibility, History.
class PillToolbar extends StatelessWidget {
  const PillToolbar({
    super.key,
    required this.count,
    required this.onCopy,
    required this.onClear,
    required this.onTogglePause,
    required this.onToggleVisibility,
    required this.onHistory,
    required this.onCollapse,
    required this.isPaused,
    required this.isVisible,
  });

  final int count;
  final VoidCallback onCopy;
  final VoidCallback onClear;
  final VoidCallback onTogglePause;
  final VoidCallback onToggleVisibility;
  final VoidCallback onHistory;
  final VoidCallback onCollapse;
  final bool isPaused;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo + collapse
          InkWell(
            onTap: onCollapse,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy_outlined, size: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Copy
          _PillButton(
            icon: Icons.content_copy_rounded,
            label: 'Copy ($count)',
            enabled: count > 0,
            onTap: onCopy,
          ),
          _PillButton(
            icon: Icons.delete_outline_rounded,
            label: 'Clear',
            enabled: count > 0,
            onTap: onClear,
          ),
          Container(width: 1, height: 24, color: scheme.outlineVariant, margin: const EdgeInsets.symmetric(horizontal: 4)),
          IconButton(
            tooltip: isPaused ? 'Resume' : 'Pause',
            icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 18),
            onPressed: onTogglePause,
            style: IconButton.styleFrom(
              backgroundColor: isPaused ? scheme.primaryContainer : null,
              foregroundColor: isPaused ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            tooltip: isVisible ? 'Hide markers' : 'Show markers',
            icon: Icon(isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 18),
            onPressed: onToggleVisibility,
          ),
          IconButton(
            tooltip: 'History',
            icon: Badge(
              label: count > 0 ? Text('$count') : null,
              isLabelVisible: count > 0,
              child: const Icon(Icons.history_rounded, size: 18),
            ),
            onPressed: onHistory,
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Collapse',
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: onCollapse,
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.icon, required this.label, required this.enabled, required this.onTap});
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
