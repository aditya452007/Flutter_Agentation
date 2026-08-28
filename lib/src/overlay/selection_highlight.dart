import 'package:flutter/material.dart';
import 'package:flutter_agnetation/src/context/geometry.dart';
import 'package:flutter_agnetation/src/overlay/tokens.dart';

/// Pure presentational highlight — stroke border aligned to [bounds].
class SelectionHighlight extends StatelessWidget {
  const SelectionHighlight({
    super.key,
    required this.bounds,
    required this.label,
  });

  final RectInfo? bounds;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (bounds == null) {
      return IgnorePointer(
        child: Align(
          alignment: Alignment.topLeft,
          child: _Badge(label: label),
        ),
      );
    }
    final media = MediaQuery.maybeOf(context);
    final disableAnimations = media?.disableAnimations ?? false;
    final position = Positioned(
      left: bounds!.x,
      top: bounds!.y,
      width: bounds!.width,
      height: bounds!.height,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: AgentationTokens.strokeWidth,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Positioned(
              top: -20,
              left: 0,
              child: _Badge(label: label),
            ),
          ],
        ),
      ),
    );
    if (disableAnimations) return position;
    return AnimatedPositioned(
      duration: AgentationTokens.highlightDuration,
      curve: Curves.easeOutCubic,
      left: bounds!.x,
      top: bounds!.y,
      width: bounds!.width,
      height: bounds!.height,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: AgentationTokens.strokeWidth,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Positioned(
              top: -20,
              left: 0,
              child: _Badge(label: label),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AgentationColors>();
    final bg = colors?.badgeBackground ?? Theme.of(context).colorScheme.primaryContainer;
    final fg = colors?.badgeForeground ?? Theme.of(context).colorScheme.onPrimaryContainer;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AgentationTokens.badgeRadius),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
        ),
      ),
    );
  }
}
