import 'package:flutter/material.dart';
import 'package:flutter_agnetation/src/context/context_model.dart';
import 'package:flutter_agnetation/src/exporter/clipboard_service.dart';
import 'package:flutter_agnetation/src/exporter/markdown_exporter.dart';

class CopyButton extends StatelessWidget {
  const CopyButton({
    super.key,
    required this.model,
    required this.exporter,
    required this.clipboard,
  });

  final ContextModel? model;
  final MarkdownExporter exporter;
  final ClipboardService clipboard;

  @override
  Widget build(BuildContext context) {
    final enabled = model != null;
    return FilledButton.icon(
      onPressed: enabled
          ? () async {
              final markdown = exporter.export(model!);
              try {
                await clipboard.copy(markdown);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied'), duration: Duration(seconds: 2)),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copy failed — select again')),
                  );
                }
              }
            }
          : null,
      icon: const Icon(Icons.content_copy, size: 18),
      label: const Text('Copy Markdown'),
    );
  }
}
