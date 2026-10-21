import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  test('S-2 criterion 1: example course A shows the current grade and coverage', () {
    final r = run(courseA());

    expect(r.results.gradeLine, 'Current grade 78.75% (C)');
    expect(r.results.coverageLine,
        'Based on completed work: 40.00% of the course');
  });

  test('S-2 criterion 2: with nothing marked, no grade is shown and the user is asked for points', () {
    final rows = [for (final a in courseA()) a.copyWith(pointsEarned: '')];
    final r = run(rows);

    expect(r.results.gradeLine, isNull);
    expect(r.results.coverageLine, isNull);
    expect(r.results.resultsMessage, enterPointsMessage);
  });

  test('S-2 criterion 3: 79.99 shows C and 80 shows B', () {
    expect(run([row(weight: '100', max: '100', earned: '79.99')]).results.gradeLine,
        'Final grade 79.99% (C)');
    expect(run([row(weight: '100', max: '100', earned: '80')]).results.gradeLine,
        'Final grade 80.00% (B)');
  });

  test('S-2 criterion 4: 179.99 out of 200 rounds half up to 90.00% (A)', () {
    final r = run([row(weight: '100', max: '200', earned: '179.99')]);

    expect(r.results.gradeLine, 'Final grade 90.00% (A)');
  });

  test('S-2 criterion 5: all marked assessments at 0 show 0.00% (F) and no error', () {
    final r = run([
      quiz.copyWith(pointsEarned: '0'),
      midterm.copyWith(pointsEarned: '0'),
      finalExam(),
    ]);

    expect(fieldErrors(r), isEmpty);
    expect(r.results.gradeLine, 'Current grade 0.00% (F)');
  });

  test('S-2 criterion 6: 10000 out of 10000 shows 100.00% (A)', () {
    final r = run([row(weight: '100', max: '10000', earned: '10000')]);

    expect(r.results.gradeLine, 'Final grade 100.00% (A)');
  });
}
