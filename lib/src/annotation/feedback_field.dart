import 'package:flutter/material.dart';
import 'package:flutter_agnetation/src/annotation/annotation_manager.dart';

class FeedbackField extends StatelessWidget {
  const FeedbackField({
    super.key,
    required this.manager,
    this.enabled = true,
  });

  final AnnotationManager manager;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Developer feedback',
      child: TextField(
        enabled: enabled,
        maxLines: 3,
        minLines: 1,
        decoration: InputDecoration(
          hintText: enabled ? 'Describe the change… (e.g., Make more rounded + taller)' : 'Select a widget to annotate',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: manager.setNote,
      ),
    );
  }
}
