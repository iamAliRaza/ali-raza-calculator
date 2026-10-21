import 'package:flutter_test/flutter_test.dart';
import 'package:grade_calculator/grading/grading.dart';

import 'fixtures.dart';

void main() {
  test('S-3 criterion 1: non-numbers in an assessment field show "Enter a number"', () {
    const bad = ['abc', '1,000', '1e3', '0x10', '85,5', 'NaN', 'Infinity'];
    for (final (label, set, error) in numberFields) {
      for (final value in bad) {
        final reason = '$label = "$value"';
        final r = run([quiz, set(midterm, value), finalExam()]);

        expect(error(r.assessments[1]), 'Enter a number', reason: reason);
        expectOnlyFixMessage(r, reason: reason);
      }
    }
  });

  test('S-3 criterion 2: plain decimals with spaces, leading zeros, a bare point or a plus sign are accepted', () {
    // value typed -> value shown, letter for that value as a grade
    const accepted = {
      ' 85 ': ('85.00', 'B'),
      '007': ('7.00', 'F'),
      '.5': ('0.50', 'F'),
      '5.': ('5.00', 'F'),
      '+5': ('5.00', 'F'),
    };
    for (final MapEntry(key: value, value: (shown, letter)) in accepted.entries) {
      final weight = run([row(weight: value)]);
      expect(fieldErrors(weight), isEmpty, reason: 'Weight = "$value"');
      expect(weight.results.weightsLine, 'Weights total: $shown%',
          reason: 'Weight = "$value"');

      final max = run([row(weight: '100', max: value)]);
      expect(fieldErrors(max), isEmpty, reason: 'Max points = "$value"');

      final earned = run([row(weight: '100', max: '100', earned: value)]);
      expect(fieldErrors(earned), isEmpty, reason: 'Points earned = "$value"');
      expect(earned.results.gradeLine, 'Final grade $shown% ($letter)',
          reason: 'Points earned = "$value"');
    }
  });

  test('S-3 criterion 3: "-0" in Points earned counts as 0', () {
    final r = run([row(weight: '100', max: '100', earned: '-0')]);

    expect(fieldErrors(r), isEmpty);
    expect(r.results.gradeLine, 'Final grade 0.00% (F)');
  });

  test('S-3 criterion 4: a field with only spaces is blank', () {
    final unmarked = run([
      quiz.copyWith(pointsEarned: '   '),
      midterm.copyWith(pointsEarned: ' '),
      finalExam('  '),
    ]);
    expect(fieldErrors(unmarked), isEmpty);
    expect(unmarked.results.resultsMessage, enterPointsMessage);

    final spacesRow = run([
      ...courseA(),
      const AssessmentInput(
          name: '  ', weight: ' ', maxPoints: '   ', pointsEarned: ' '),
    ]);
    expect(fieldErrors(spacesRow), isEmpty);
    expect(spacesRow.results.gradeLine, 'Current grade 78.75% (C)');
  });

  test('S-3 criterion 5: more than 2 decimal places shows "Use at most 2 decimal places"', () {
    for (final (label, set, error) in numberFields) {
      for (final value in ['0.001', '5.000']) {
        final reason = '$label = "$value"';
        final r = run([quiz, set(midterm, value), finalExam()]);

        expect(error(r.assessments[1]), 'Use at most 2 decimal places',
            reason: reason);
        expectOnlyFixMessage(r, reason: reason);
      }
    }
  });

  test('S-3 criterion 6: max points 0 shows the range message and no grade', () {
    final r = run([quiz, midterm.copyWith(maxPoints: '0'), finalExam()]);

    expect(r.assessments[1].maxPointsError,
        'Max points must be more than 0 and at most 10,000');
    expect(r.results.gradeLine, isNull);
  });

  test('S-3 criterion 7: max points above 10000 shows the range message', () {
    for (final value in ['10000.01', '1000000000']) {
      final r = run([quiz, midterm.copyWith(maxPoints: value), finalExam()]);

      expect(r.assessments[1].maxPointsError,
          'Max points must be more than 0 and at most 10,000',
          reason: 'Max points = "$value"');
    }
  });

  test('S-3 criterion 8: weight 0 or 100.01 shows the weight range message', () {
    for (final value in ['0', '100.01']) {
      final r = run([quiz, midterm.copyWith(weight: value), finalExam()]);

      expect(r.assessments[1].weightError,
          'Weight must be more than 0 and at most 100',
          reason: 'Weight = "$value"');
    }
  });

  test('S-3 criterion 9: negative points earned shows "Points earned cannot be negative"', () {
    final r = run([quiz, midterm.copyWith(pointsEarned: '-5'), finalExam()]);

    expect(r.assessments[1].pointsEarnedError,
        'Points earned cannot be negative');
  });

  test('S-3 criterion 10: points earned above max points shows an error', () {
    final r = run([row(weight: '100', max: '50', earned: '51')]);

    expect(r.assessments.single.pointsEarnedError,
        'Points earned cannot be more than max points');
  });

  test('S-3 criterion 11: changing Max points rechecks Points earned', () {
    final lowered = run([row(weight: '100', max: '50', earned: '75')]);
    expect(lowered.assessments.single.pointsEarnedError,
        'Points earned cannot be more than max points');

    final restored = run([row(weight: '100', max: '100', earned: '75')]);
    expect(restored.assessments.single.pointsEarnedError, isNull);
  });

  test('S-3 criterion 12: with Max points 0, only Max points shows an error', () {
    final r = run([row(weight: '100', max: '0', earned: '75')]);

    expect(r.assessments.single.maxPointsError, isNotNull);
    expect(r.assessments.single.pointsEarnedError, isNull);
  });

  test('S-3 criterion 13: invalid Max points still lets Points earned show its own error', () {
    final r = run([row(weight: '100', max: '0', earned: 'abc')]);

    expect(r.assessments.single.maxPointsError,
        'Max points must be more than 0 and at most 10,000');
    expect(r.assessments.single.pointsEarnedError, 'Enter a number');
  });

  test('S-3 criterion 14: missing Weight or Max points shows "Enter a weight" or "Enter max points"', () {
    final noWeight = run([row(name: 'Quiz', max: '20', earned: '18')]);
    expect(noWeight.assessments.single.weightError, 'Enter a weight');

    final noMax = run([row(weight: '10', earned: '18')]);
    expect(noMax.assessments.single.maxPointsError, 'Enter max points');
  });

  test('S-3 criterion 15: an assessment error hides every result but keeps the target letter', () {
    final r = run([quiz, midterm.copyWith(pointsEarned: 'abc'), finalExam()],
        target: '85');

    expectOnlyFixMessage(r);
    expect(r.targetLetter, '(B)');
    expect(r.targetError, isNull);
  });

  test('S-3 criterion 16: correcting the value removes the error and brings the results back', () {
    final broken =
        run([quiz, midterm.copyWith(pointsEarned: 'abc'), finalExam()]);
    expect(broken.assessments[1].pointsEarnedError, 'Enter a number');

    final fixed = run(courseA());
    expect(fieldErrors(fixed), isEmpty);
    expect(fixed.results.resultsMessage, isNull);
    expect(fixed.results.gradeLine, 'Current grade 78.75% (C)');
  });

  test('S-3 criterion 17: removing the only row with an error brings the results back', () {
    final broken =
        run([quiz, midterm.copyWith(pointsEarned: 'abc'), finalExam()]);
    expectOnlyFixMessage(broken);

    final removed = run([quiz, finalExam()]);
    expect(fieldErrors(removed), isEmpty);
    expect(removed.results.resultsMessage, isNull);
    expect(removed.results.gradeLine, 'Current grade 90.00% (A)');
  });
}
