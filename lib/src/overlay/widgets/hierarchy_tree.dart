import 'package:flutter/material.dart';

class HierarchyTree extends StatelessWidget {
  const HierarchyTree({
    super.key,
    required this.path,
    this.selected,
  });

  final List<String> path;
  final String? selected;

  String buildIndentedTree() {
    final buffer = StringBuffer();
    for (var i = 0; i < path.length; i++) {
      final indent = '  ' * i;
      final marker = i == path.length - 1 ? ' \u25c4' : '';
      buffer.writeln('$indent\u2514\u2500\u2500 ${path[i]}$marker');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const Text('_Hierarchy unavailable_');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < path.length; i++)
          Padding(
            padding: EdgeInsets.only(left: i * 8),
            child: Row(
              children: [
                Text(
                  '└── ${path[i]}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: i == path.length - 1 ? FontWeight.bold : null,
                        color: i == path.length - 1 ? Theme.of(context).colorScheme.primary : null,
                      ),
                ),
                if (i == path.length - 1) ...[
                  const SizedBox(width: 4),
                  const Text('◄'),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
