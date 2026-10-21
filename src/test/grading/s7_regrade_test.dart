import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  test('S-7 criterion 1: changing Final exam from 88 to 97.5 shows "Final grade 90.00% (A)"', () {
    expect(run(courseA(finalEarned: '88')).results.gradeLine,
        'Final grade 84.30% (B)');
    expect(run(courseA(finalEarned: '97.5')).results.gradeLine,
        'Final grade 90.00% (A)');
  });

  test('S-7 criterion 2: Midterm max points 0 hides the grade, and 100 brings it back', () {
    final broken =
        run([quiz, midterm.copyWith(maxPoints: '0'), finalExam('88')]);
    expect(broken.assessments[1].maxPointsError, isNotNull);
    expect(broken.assessments[1].pointsEarnedError, isNull);
    expectOnlyFixMessage(broken);

    final restored = run(courseA(finalEarned: '88'));
    expect(restored.results.gradeLine, 'Final grade 84.30% (B)');
  });

  test('S-7 criterion 3: clearing Final exam points earned shows the current grade', () {
    expect(run(courseA(finalEarned: '88')).results.gradeLine,
        'Final grade 84.30% (B)');
    expect(run(courseA()).results.gradeLine, 'Current grade 78.75% (C)');
  });

  test('S-7 criterion 4: removing the Quiz row warns about weights and shows 83.67% (B)', () {
    final r = run([midterm, finalExam('88')]);

    expect(r.results.weightsLine, 'Weights total: 90.00%');
    expect(r.results.weightsWarning, weightsWarning);
    expect(r.results.gradeLine, 'Current grade 83.67% (B)');
  });
}
