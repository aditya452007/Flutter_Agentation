import 'package:flutter/material.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/overlay/widgets/hierarchy_tree.dart';
import 'package:flutter_agnetation/src/overlay/widgets/info_row.dart';
import 'package:flutter_agnetation/src/overlay/widgets/unavailable_label.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.facts});

  final WidgetFacts? facts;

  @override
  Widget build(BuildContext context) {
    if (facts == null) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Select a widget to inspect')));
    }
    return InfoPanelContent(facts: facts!);
  }
}

class InfoPanelContent extends StatelessWidget {
  const InfoPanelContent({super.key, required this.facts});

  final WidgetFacts facts;

  @override
  Widget build(BuildContext context) {
    final sourceString = facts.sourceLocation != null
        ? '${facts.sourceLocation!.file}:${facts.sourceLocation!.line}:${facts.sourceLocation!.column}'
        : 'Source unavailable in this build';
    final sourceUnavailable = facts.sourceLocation == null;

    final boundsString = facts.bounds != null
        ? 'X: ${facts.bounds!.x.toStringAsFixed(0)} Y: ${facts.bounds!.y.toStringAsFixed(0)} W: ${facts.bounds!.width.toStringAsFixed(0)} H: ${facts.bounds!.height.toStringAsFixed(0)}'
        : 'Bounds unavailable';

    return Card(
      margin: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Widget', style: Theme.of(context).textTheme.titleSmall),
            InfoRow(label: 'Widget', value: facts.widgetType),
            InfoRow(label: 'Runtime', value: facts.runtimeTypeName),
            const Divider(),
            Text('Source', style: Theme.of(context).textTheme.titleSmall),
            if (sourceUnavailable) UnavailableLabel(text: sourceString) else InfoRow(label: 'File', value: sourceString),
            const Divider(),
            Text('Geometry', style: Theme.of(context).textTheme.titleSmall),
            if (facts.bounds == null)
              const UnavailableLabel(text: 'Bounds unavailable')
            else
              InfoRow(label: 'Bounds', value: boundsString),
            const Divider(),
            Text('Hierarchy', style: Theme.of(context).textTheme.titleSmall),
            HierarchyTree(path: facts.hierarchy),
            const Divider(),
            Text('Runtime Details', style: Theme.of(context).textTheme.titleSmall),
            if (facts.text != null) InfoRow(label: 'Text', value: facts.text!),
            if (facts.key != null) InfoRow(label: 'Key', value: facts.key!),
            if (facts.semantics != null) InfoRow(label: 'Semantics', value: facts.semantics!),
            if (facts.properties != null)
              for (final e in facts.properties!.entries) InfoRow(label: e.key, value: e.value),
            if (facts.text == null && facts.key == null && facts.semantics == null && facts.properties == null)
              const Text('No additional properties'),
            const Divider(),
            // L06/L07 placeholders
            Text('Feedback', style: Theme.of(context).textTheme.titleSmall),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Feedback field (L06)'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: null, icon: Icon(Icons.content_copy), label: Text('Copy Markdown (L07)')),
          ],
        ),
      ),
    );
  }
}
