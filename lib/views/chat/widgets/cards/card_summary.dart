import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CardSummary extends StatelessWidget {
  final String summary;
  final bool isExpanded;

  const CardSummary({
    super.key,
    required this.summary,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SelectionArea(
        child: MarkdownBody(
          data: summary,
          styleSheet: MarkdownStyleSheet(
            p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.9),
                ),
            strong: TextStyle(
                color: colorScheme.primary, fontWeight: FontWeight.w600),
            h1: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            h2: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            code: TextStyle(
              backgroundColor: colorScheme.surfaceContainerHighest,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
