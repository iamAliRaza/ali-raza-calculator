import 'package:flutter/material.dart';

import '../grading/grading.dart';
import 'assessment_row.dart';
import 'results_card.dart';

/// Holds all app state: the text of every field. Everything shown is worked
/// out from that text by [evaluate] on every build, so results follow each
/// keystroke.
class GradeCalculatorPage extends StatefulWidget {
  const GradeCalculatorPage({super.key});

  @override
  State<GradeCalculatorPage> createState() => _GradeCalculatorPageState();
}

class _GradeCalculatorPageState extends State<GradeCalculatorPage> {
  static const _wideLayoutMinWidth = 720.0;
  static const _maxContentWidth = 1100.0;
  static const _summaryWidth = 320.0;

  final _rows = <AssessmentFields>[];
  final _target = TextEditingController();
  var _nextRowId = 0;

  @override
  void initState() {
    super.initState();
    _rows.add(AssessmentFields(_nextRowId++));
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    _target.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  void _addRow() {
    final row = AssessmentFields(_nextRowId++);
    setState(() => _rows.add(row));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => row.nameFocus.requestFocus());
  }

  void _removeRow(AssessmentFields row) {
    setState(() => _rows.remove(row));
    // Its fields are still on screen until this frame is drawn.
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = evaluate(GradeInput(
      assessments: [for (final row in _rows) row.toInput()],
      target: _target.text,
    ));

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                child: LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth >= _wideLayoutMinWidth;
                  final assessments = _assessments(context, result);
                  final summary = _summary(context, result);
                  return Padding(
                    padding: EdgeInsets.all(wide ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Grade calculator',
                            style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 24),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: assessments),
                              const SizedBox(width: 32),
                              SizedBox(width: _summaryWidth, child: summary),
                            ],
                          )
                        // On phones the result sits above the rows, so it
                        // stays in view while marks are typed.
                        else ...[
                          summary,
                          const SizedBox(height: 24),
                          assessments,
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _assessments(BuildContext context, GradeResult result) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Assessments', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        for (final (i, row) in _rows.indexed)
          AssessmentRow(
            key: ValueKey(row.id),
            fields: row,
            errors: result.assessments[i],
            canRemove: result.canRemoveAssessment,
            onChanged: _changed,
            onRemove: () => _removeRow(row),
          ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: result.canAddAssessment ? _addRow : null,
              icon: const Icon(Icons.add),
              label: const Text('Add assessment'),
            ),
            if (result.rowLimitMessage case final message?)
              Text(message,
                  key: const ValueKey('rowLimitMessage'),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  Widget _summary(BuildContext context, GradeResult result) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                key: const ValueKey('targetField'),
                controller: _target,
                keyboardType: numberKeyboard,
                onChanged: (_) => _changed(),
                decoration: InputDecoration(
                  labelText: 'Target grade',
                  suffixText: '%',
                  errorText: result.targetError,
                  errorMaxLines: 3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (result.targetLetter case final letter?)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(letter,
                    key: const ValueKey('targetLetter'),
                    style: theme.textTheme.titleMedium),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ResultsCard(results: result.results),
      ],
    );
  }
}
