import 'package:flutter/material.dart';

import '../grading/grading.dart';

/// Draws the results area: each line in screen order, skipping empty ones.
/// Keys match the screen element names in docs/user-stories.md.
class ResultsCard extends StatelessWidget {
  const ResultsCard({super.key, required this.results});

  final ResultsArea results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final colors = theme.colorScheme;

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text('Results', style: text.titleMedium),
            if (results.weightsLine case final line?)
              Text(line,
                  key: const ValueKey('weightsLine'), style: text.bodyMedium),
            if (results.weightsWarning case final warning?)
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: colors.tertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(warning,
                        key: const ValueKey('weightsWarning'),
                        style:
                            text.bodyMedium?.copyWith(color: colors.tertiary)),
                  ),
                ],
              ),
            if (results.gradeLine case final line?)
              Text(line,
                  key: const ValueKey('gradeLine'), style: text.headlineSmall),
            if (results.resultsMessage case final message?)
              Text(message,
                  key: const ValueKey('resultsMessage'),
                  style: text.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant)),
            if (results.coverageLine case final line?)
              Text(line,
                  key: const ValueKey('coverageLine'),
                  style:
                      text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
            if (results.requiredScoreLine case final line?)
              Text(line,
                  key: const ValueKey('requiredScoreLine'),
                  style: text.bodyLarge),
          ],
        ),
      ),
    );
  }
}
