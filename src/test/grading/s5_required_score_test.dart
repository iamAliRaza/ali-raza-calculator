import 'package:flutter_test/flutter_test.dart';
import 'package:grade_calculator/grading/grading.dart';

import 'fixtures.dart';

void main() {
  String? requiredScore(List<AssessmentInput> rows, String target) =>
      run(rows, target: target).results.requiredScoreLine;

  test('S-5 criterion 1: target 85 shows the target letter (B)', () {
    expect(run(courseA(), target: '85').targetLetter, '(B)');
  });

  test('S-5 criterion 2: example course A, target 85 needs 89.17%', () {
    expect(requiredScore(courseA(), '85'),
        'You need at least 89.17% on each remaining assessment to reach 85.00% (B).');
  });

  test('S-5 criterion 3: example course A, target 80 needs 80.84% (rounded up)', () {
    expect(requiredScore(courseA(), '80'),
        'You need at least 80.84% on each remaining assessment to reach 80.00% (B).');
  });

  test('S-5 criterion 4: example course A, target 95 is not achievable and shows the highest reachable grade', () {
    expect(requiredScore(courseA(), '95'),
        'Not achievable: you would need 105.84% on each remaining assessment. '
        'The highest you can reach is 91.50% (A).');
  });

  test('S-5 criterion 5: a very large required score uses thousands separators', () {
    final rows = [
      row(weight: '99.99', max: '100', earned: '0'),
      row(weight: '0.01'),
    ];

    expect(requiredScore(rows, '50'),
        'Not achievable: you would need 500,000.00% on each remaining assessment. '
        'The highest you can reach is 0.01% (F).');
  });

  test('S-5 criterion 6: needing exactly 100.00% is achievable', () {
    final rows = [row(weight: '50', max: '100', earned: '80'), row(weight: '50')];

    expect(requiredScore(rows, '90'),
        'You need at least 100.00% on each remaining assessment to reach 90.00% (A).');
  });

  test('S-5 criterion 7: a target below the guaranteed grade is already secured', () {
    final rows = [row(weight: '70', max: '100', earned: '100'), row(weight: '30')];

    expect(requiredScore(rows, '60'),
        'Already secured: you will reach at least 70.00% (C) even with 0% on the remaining assessments.');
  });

  test('S-5 criterion 8: a target equal to the guaranteed grade is already secured', () {
    final rows = [row(weight: '50', max: '100', earned: '100'), row(weight: '50')];

    expect(requiredScore(rows, '50'),
        'Already secured: you will reach at least 50.00% (F) even with 0% on the remaining assessments.');
  });

  final nearMiss = [
    row(weight: '90', max: '10000', earned: '9444'),
    row(weight: '10'),
  ];

  test('S-5 criterion 9: a guaranteed 84.996 is not enough for target 85', () {
    expect(requiredScore(nearMiss, '85'),
        'You need at least 0.04% on each remaining assessment to reach 85.00% (B).');
  });

  test('S-5 criterion 10: the "at least" grade rounds down, 84.996 shows 84.99', () {
    expect(requiredScore(nearMiss, '84'),
        'Already secured: you will reach at least 84.99% (B) even with 0% on the remaining assessments.');
  });

  test('S-5 criterion 11: with nothing marked, the required score equals the target', () {
    final rows = [row(weight: '40'), row(weight: '60')];

    expect(requiredScore(rows, '75'),
        'You need at least 75.00% on each remaining assessment to reach 75.00% (C).');
  });

  test('S-5 criterion 12: with everything marked, there is no required score', () {
    expect(requiredScore(courseA(finalEarned: '88'), '85'),
        'No remaining assessments, so no required score.');
  });

  test('S-5 criterion 13: weights not totalling 100 win over "No remaining assessments"', () {
    final rows = [quiz, midterm, finalExam('88').copyWith(weight: '55')];

    expect(requiredScore(rows, '85'), weightsNot100Message);
  });

  test('S-5 criterion 14: an invalid target shows its error, hides the required score and letter, keeps the grade', () {
    for (final target in ['100.01', '-1', '85.555', 'abc']) {
      final r = run(courseA(), target: target);
      final reason = 'Target = "$target"';

      expect(r.targetError, targetErrorMessage, reason: reason);
      expect(r.results.requiredScoreLine, isNull, reason: reason);
      expect(r.targetLetter, isNull, reason: reason);
      expect(r.results.gradeLine, 'Current grade 78.75% (C)', reason: reason);
    }
  });

  test('S-5 criterion 15: an invalid target with weights not totalling 100 still shows the weights message', () {
    final r = run([quiz, midterm, finalExam().copyWith(weight: '55')],
        target: 'abc');

    expect(r.targetError, targetErrorMessage);
    expect(r.results.requiredScoreLine, weightsNot100Message);
  });

  test('S-5 criterion 16: a blank target shows no required score, letter or error', () {
    final r = run(courseA());

    expect(r.results.requiredScoreLine, isNull);
    expect(r.targetLetter, isNull);
    expect(r.targetError, isNull);
  });

  test('S-5 criterion 17: changing the target or a mark updates the required score', () {
    expect(requiredScore(courseA(), '85'),
        'You need at least 89.17% on each remaining assessment to reach 85.00% (B).');
    expect(requiredScore(courseA(), '80'),
        'You need at least 80.84% on each remaining assessment to reach 80.00% (B).');

    final remarked = [quiz, midterm.copyWith(pointsEarned: '85'), finalExam()];
    expect(requiredScore(remarked, '80'),
        'You need at least 75.84% on each remaining assessment to reach 80.00% (B).');
  });

  test('S-5 criterion 18: a target with no row in use shows its letter but no required score', () {
    final r = run([blankRow], target: '85');

    expect(r.targetLetter, '(B)');
    expect(r.results.resultsMessage, addAssessmentsMessage);
    expect(r.results.weightsLine, isNull);
    expect(r.results.requiredScoreLine, isNull);
  });
}
