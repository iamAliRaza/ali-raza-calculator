import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  void expectTotal100(List<String> weights) {
    final r = run([for (final w in weights) row(weight: w)]);

    expect(r.results.weightsLine, 'Weights total: 100.00%');
    expect(r.results.weightsWarning, isNull);
  }

  test('S-4 criterion 1: weights 10, 30 and 60 total 100.00% with no warning', () {
    expectTotal100(['10', '30', '60']);
  });

  test('S-4 criterion 2: weights 33.33, 33.33 and 33.34 total exactly 100.00%', () {
    expectTotal100(['33.33', '33.33', '33.34']);
  });

  test('S-4 criterion 3: weights 0.1, 0.2 and 99.7 total exactly 100.00%', () {
    expectTotal100(['0.1', '0.2', '99.7']);
  });

  test('S-4 criterion 4: weights totalling 95 warn, keep the current grade and withhold the required score', () {
    final r = run([quiz, midterm, finalExam().copyWith(weight: '55')],
        target: '85');

    expect(r.results.weightsLine, 'Weights total: 95.00%');
    expect(r.results.weightsWarning, weightsWarning);
    expect(r.results.gradeLine, 'Current grade 78.75% (C)');
    expect(r.results.coverageLine, isNull);
    expect(r.results.requiredScoreLine, weightsNot100Message);
    expect(r.results.gradeLine, isNot(startsWith('Final grade')));
  });

  test('S-4 criterion 5: weights totalling 100.01 warn', () {
    final r = run([row(weight: '10'), row(weight: '30'), row(weight: '60.01')]);

    expect(r.results.weightsLine, 'Weights total: 100.01%');
    expect(r.results.weightsWarning, weightsWarning);
  });

  test('S-4 criterion 6: a single Weight of 10 shows the total and the warning', () {
    final r = run([row(weight: '10')]);

    expect(r.results.weightsLine, 'Weights total: 10.00%');
    expect(r.results.weightsWarning, weightsWarning);
  });

  test('S-4 criterion 7: correcting the weights to 100 removes the warning and updates the results', () {
    final wrong = run([quiz, midterm, finalExam().copyWith(weight: '55')]);
    expect(wrong.results.weightsWarning, weightsWarning);

    final corrected = run(courseA());
    expect(corrected.results.weightsLine, 'Weights total: 100.00%');
    expect(corrected.results.weightsWarning, isNull);
    expect(corrected.results.coverageLine,
        'Based on completed work: 40.00% of the course');
  });
}
