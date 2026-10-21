import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

// UI-only criteria 2, 3, 11 and 12 are covered by widget tests.
void main() {
  test('S-1 criterion 1: opening state shows "Add your assessments" and no weights line', () {
    final r = run([blankRow]);

    expect(r.results.resultsMessage, addAssessmentsMessage);
    expect(r.results.weightsLine, isNull);
    expect(r.results.weightsWarning, isNull);
    expect(r.results.gradeLine, isNull);
    expect(r.results.coverageLine, isNull);
    expect(r.results.requiredScoreLine, isNull);
    expect(fieldErrors(r), isEmpty);
  });

  test('S-1 criterion 4: with only one row, Remove is disabled', () {
    expect(run([blankRow]).canRemoveAssessment, isFalse);
    expect(run([blankRow, blankRow]).canRemoveAssessment, isTrue);
  });

  test('S-1 criterion 5: with 20 rows, Add assessment is disabled and the row limit message shows', () {
    final r = run(List.filled(20, blankRow));

    expect(r.canAddAssessment, isFalse);
    expect(r.rowLimitMessage, 'You can add up to 20 assessments.');
  });

  test('S-1 criterion 6: removing a row at 20 enables Add assessment and hides the row limit message', () {
    final r = run(List.filled(19, blankRow));

    expect(r.canAddAssessment, isTrue);
    expect(r.rowLimitMessage, isNull);
  });

  test('S-1 criterion 7: a blank Name is calculated as normal', () {
    final rows = [for (final a in courseA()) a.copyWith(name: '')];
    final r = run(rows);

    expect(fieldErrors(r), isEmpty);
    expect(r.results.gradeLine, 'Current grade 78.75% (C)');
  });

  test('S-1 criterion 8: a row with every field blank is ignored', () {
    final r = run([...courseA(), blankRow]);

    expect(fieldErrors(r), isEmpty);
    expect(r.results.weightsLine, 'Weights total: 100.00%');
    expect(r.results.gradeLine, 'Current grade 78.75% (C)');
    expect(r.results.coverageLine,
        'Based on completed work: 40.00% of the course');
  });

  test('S-1 criterion 9: a row with only Name is not in use and shows no errors', () {
    final alone = run([row(name: 'Final exam')]);
    expect(fieldErrors(alone), isEmpty);
    expect(alone.results.resultsMessage, addAssessmentsMessage);
    expect(alone.results.weightsLine, isNull);

    final withOthers = run([quiz, midterm, row(name: 'Final exam')]);
    expect(fieldErrors(withOthers), isEmpty);
    expect(withOthers.results.weightsLine, 'Weights total: 40.00%');
    expect(withOthers.results.gradeLine, 'Current grade 78.75% (C)');
  });

  test('S-1 criterion 10: a row with only Weight is a valid upcoming assessment', () {
    final r = run([row(weight: '100')]);

    expect(fieldErrors(r), isEmpty);
    expect(r.results.resultsMessage, enterPointsMessage);
  });
}
