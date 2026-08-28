import 'package:flutter/material.dart';

class UnavailableLabel extends StatelessWidget {
  const UnavailableLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
            fontFamily: 'monospace',
          ),
    );
  }
}
