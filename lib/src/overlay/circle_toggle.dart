import 'package:flutter/material.dart';

/// 40dp circle with logo + badge count. Entry point like Next.js Agentation.
class CircleToggle extends StatelessWidget {
  const CircleToggle({
    super.key,
    required this.onTap,
    this.count = 0,
  });

  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Open Agentation',
      button: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: scheme.primary,
            shape: const CircleBorder(),
            elevation: 6,
            shadowColor: Colors.black26,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.smart_toy_outlined, size: 20, color: Colors.white),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.error,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onError,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
