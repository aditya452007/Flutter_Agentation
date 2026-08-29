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
    return Semantics(
      label: 'Open Agentation',
      button: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: const Color(0xCC0A0A0A),
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: const Color(0x0D000000),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              hoverColor: const Color(0x14FFFFFF),
              highlightColor: const Color(0x1FFFFFFF),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.smart_toy_outlined, size: 20, color: Color(0xFFF5F0EB)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black,
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
