import 'package:flutter/material.dart';

/// Branded inspection toggle — logo pill that is always visible.
/// Design goal: unambiguous entry point (like Next.js Agentation's floating badge),
/// not a tiny icon that blends into the scaffold.
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
    final scheme = Theme.of(context).colorScheme;
    // Use high-contrast container colors so the toggle never blends into surface
    final bg = isEnabled ? scheme.primary : scheme.secondaryContainer;
    final fg = isEnabled ? scheme.onPrimary : scheme.onSecondaryContainer;
    final borderColor = isEnabled ? scheme.primary : scheme.outlineVariant;

    return Semantics(
      label: isEnabled ? 'Exit inspection' : 'Enter inspection',
      button: true,
      child: Material(
        color: bg,
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo mark — circular badge with agent icon
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: fg.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: fg.withOpacity(0.3)),
                  ),
                  child: Icon(
                    isEnabled ? Icons.center_focus_strong : Icons.smart_toy_outlined,
                    size: 16,
                    color: fg,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnabled ? 'Inspecting…' : 'Agentation',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                    ),
                    Text(
                      isEnabled ? 'Tap a widget • Tap to exit' : 'Tap to inspect UI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: fg.withOpacity(0.85),
                            height: 1.0,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  isEnabled ? Icons.close_rounded : Icons.chevron_right_rounded,
                  size: 16,
                  color: fg.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
