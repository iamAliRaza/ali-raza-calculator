import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  test('S-6 criterion 1: example course A with Final exam 88 shows "Final grade 84.30% (B)"', () {
    final r = run(courseA(finalEarned: '88'));

    expect(r.results.gradeLine, 'Final grade 84.30% (B)');
    expect(r.results.coverageLine, isNull);
  });

  test('S-6 criterion 2: with Final exam unmarked the result is a Current grade', () {
    final r = run(courseA());

    expect(r.results.gradeLine, startsWith('Current grade'));
  });

  test('S-6 criterion 3: all marked with weights totalling 95 is a Current grade with the warning', () {
    final r = run([quiz, midterm, finalExam('88').copyWith(weight: '55')]);

    expect(r.results.gradeLine, startsWith('Current grade'));
    expect(r.results.weightsWarning, weightsWarning);
  });

  test('S-6 criterion 4: weights 33.33, 33.33 and 33.34 at 90, 80 and 70 show "Final grade 80.00% (B)"', () {
    final r = run([
      row(weight: '33.33', max: '100', earned: '90'),
      row(weight: '33.33', max: '100', earned: '80'),
      row(weight: '33.34', max: '100', earned: '70'),
    ]);

    expect(r.results.gradeLine, 'Final grade 80.00% (B)');
  });

  test('S-6 criterion 5: the letter always matches the percentage shown', () {
    // The grade scale is written out here on purpose, so this test does not
    // check the app's scale against itself.
    String expectedLetter(int hundredths) {
      if (hundredths >= 9000) return 'A';
      if (hundredths >= 8000) return 'B';
      if (hundredths >= 7000) return 'C';
      if (hundredths >= 6000) return 'D';
      return 'F';
    }

    final gradeLine =
        RegExp(r'^(?:Current|Final) grade ([\d,]+)\.(\d{2})% \(([A-F])\)$');

    for (var cents = 0; cents <= 10000; cents++) {
      final earned =
          '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
      final line =
          run([row(weight: '100', max: '100', earned: earned)]).results.gradeLine;
      final reason = 'Points earned = $earned, grade line = $line';

      final match = gradeLine.firstMatch(line ?? '');
      expect(match, isNotNull, reason: reason);
      final shown = int.parse(match!.group(1)!.replaceAll(',', '')) * 100 +
          int.parse(match.group(2)!);
      expect(match.group(3), expectedLetter(shown), reason: reason);
    }
  });

  test('S-6 criterion 6: the grade scale boundaries', () {
    const table = [
      ('100', '0', 'Final grade 0.00% (F)'),
      ('100', '59.99', 'Final grade 59.99% (F)'),
      ('100', '60', 'Final grade 60.00% (D)'),
      ('100', '69.99', 'Final grade 69.99% (D)'),
      ('100', '70', 'Final grade 70.00% (C)'),
      ('100', '79.99', 'Final grade 79.99% (C)'),
      ('100', '80', 'Final grade 80.00% (B)'),
      ('100', '89.99', 'Final grade 89.99% (B)'),
      ('100', '90', 'Final grade 90.00% (A)'),
      ('100', '100', 'Final grade 100.00% (A)'),
      ('10000', '8999.4', 'Final grade 89.99% (B)'),
      ('10000', '8999.5', 'Final grade 90.00% (A)'),
    ];
    for (final (max, earned, expected) in table) {
      final r = run([row(weight: '100', max: max, earned: earned)]);

      expect(r.results.gradeLine, expected, reason: '$earned out of $max');
    }
  });
}
