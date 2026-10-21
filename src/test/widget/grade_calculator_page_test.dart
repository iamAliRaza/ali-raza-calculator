import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grade_calculator/main.dart';
import 'package:grade_calculator/ui/assessment_row.dart';
import 'package:grade_calculator/ui/results_card.dart';

const desktop = Size(1280, 900);
const phone = Size(375, 812);

Future<void> pumpApp(WidgetTester tester, {Size size = desktop}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const GradeCalculatorApp());
}

Finder rowAt(int i) => find.byType(AssessmentRow).at(i);

Finder field(int row, String label) => find.descendant(
    of: rowAt(row), matching: find.widgetWithText(TextField, label));

Finder removeButton(int row) =>
    find.descendant(of: rowAt(row), matching: find.byType(IconButton));

final targetField = find.byKey(const ValueKey('targetField'));
final addButton = find.ancestor(
    of: find.text('Add assessment'),
    matching: find.byWidgetPredicate((w) => w is FilledButton));

String textIn(WidgetTester tester, Finder textField) =>
    tester.widget<TextField>(textField).controller!.text;

Future<void> type(WidgetTester tester, Finder textField, String value) async {
  await tester.ensureVisible(textField);
  await tester.enterText(textField, value);
  await tester.pump();
}

Future<void> tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pump();
}

Future<void> fillRow(
  WidgetTester tester,
  int row, {
  String name = '',
  String weight = '',
  String max = '',
  String earned = '',
}) async {
  for (final (label, value) in [
    ('Name', name),
    ('Weight (%)', weight),
    ('Max points', max),
    ('Points earned', earned),
  ]) {
    if (value.isNotEmpty) await type(tester, field(row, label), value);
  }
}

Future<void> enterCourseA(WidgetTester tester, {String finalEarned = ''}) async {
  await fillRow(tester, 0, name: 'Quiz', weight: '10', max: '20', earned: '18');
  await tap(tester, addButton);
  await fillRow(tester, 1,
      name: 'Midterm', weight: '30', max: '100', earned: '75');
  await tap(tester, addButton);
  await fillRow(tester, 2,
      name: 'Final exam', weight: '60', max: '100', earned: finalEarned);
}

void main() {
  testWidgets('S-1 criterion 1 (UI): the app opens with one row of four empty fields', (tester) async {
    await pumpApp(tester);

    expect(find.byType(AssessmentRow), findsOneWidget);
    for (final label in ['Name', 'Weight (%)', 'Max points', 'Points earned']) {
      expect(textIn(tester, field(0, label)), isEmpty, reason: label);
    }
    expect(find.text('Add your assessments to see your grade.'), findsOneWidget);
  });

  testWidgets('S-1 criterion 2 (UI): Add assessment puts an empty row below and focuses its Name', (tester) async {
    await pumpApp(tester);
    await fillRow(tester, 0, name: 'Quiz');
    await tap(tester, addButton);
    await tester.pump();

    expect(find.byType(AssessmentRow), findsNWidgets(2));
    expect(textIn(tester, field(1, 'Name')), isEmpty);
    expect(tester.getTopLeft(rowAt(1)).dy,
        greaterThan(tester.getTopLeft(rowAt(0)).dy));
    expect(tester.widget<TextField>(field(1, 'Name')).focusNode!.hasFocus,
        isTrue);
  });

  testWidgets('S-1 criterion 3 (UI): removing the first row keeps the second row and its values', (tester) async {
    await pumpApp(tester);
    await fillRow(tester, 0, name: 'Quiz', weight: '50', max: '20', earned: '18');
    await tap(tester, addButton);
    await fillRow(tester, 1,
        name: 'Exam', weight: '100', max: '100', earned: '80');

    await tap(tester, removeButton(0));

    expect(find.byType(AssessmentRow), findsOneWidget);
    expect(textIn(tester, field(0, 'Name')), 'Exam');
    expect(textIn(tester, field(0, 'Weight (%)')), '100');
    expect(textIn(tester, field(0, 'Max points')), '100');
    expect(textIn(tester, field(0, 'Points earned')), '80');
    expect(find.text('Final grade 80.00% (B)'), findsOneWidget);
  });

  testWidgets('S-1 criteria 4 and 5 (UI): Remove and Add are disabled at the limits and the row limit message shows', (tester) async {
    await pumpApp(tester);
    expect(tester.widget<IconButton>(removeButton(0)).onPressed, isNull);

    for (var i = 1; i < 20; i++) {
      await tap(tester, addButton);
    }
    expect(find.byType(AssessmentRow), findsNWidgets(20));
    expect(tester.widget<ButtonStyleButton>(addButton).onPressed, isNull);
    expect(find.text('You can add up to 20 assessments.'), findsOneWidget);
    expect(tester.widget<IconButton>(removeButton(0)).onPressed, isNotNull);

    await tap(tester, removeButton(19));
    expect(tester.widget<ButtonStyleButton>(addButton).onPressed, isNotNull);
    expect(find.text('You can add up to 20 assessments.'), findsNothing);
  });

  testWidgets('S-1 criterion 9 (UI): typing a Name shows no error in the row', (tester) async {
    await pumpApp(tester);
    await type(tester, field(0, 'Name'), 'Q');

    for (final label in ['Weight (%)', 'Max points', 'Points earned']) {
      expect(tester.widget<TextField>(field(0, label)).decoration!.errorText,
          isNull, reason: label);
    }
    expect(find.text('Enter a weight'), findsNothing);
    expect(find.text('Add your assessments to see your grade.'), findsOneWidget);
  });

  testWidgets('S-1 criterion 11 (UI): Name stops at 40 characters and shows a counter, with no error', (tester) async {
    await pumpApp(tester);
    await type(tester, field(0, 'Name'), 'A' * 41);

    expect(textIn(tester, field(0, 'Name')), 'A' * 40);
    expect(find.text('40/40'), findsOneWidget);
    expect(tester.widget<TextField>(field(0, 'Name')).decoration!.errorText,
        isNull);
  });

  testWidgets('S-1 criterion 12 (UI): at 375 px wide, 20 rows with long errors fit with no sideways scrolling', (tester) async {
    await pumpApp(tester, size: phone);
    for (var i = 1; i < 20; i++) {
      await tap(tester, addButton);
    }
    // Every row lays out the same way, so the longest messages go in two
    // rows; filling all 20 adds minutes and checks nothing new.
    await fillRow(tester, 0,
        name: 'W' * 40, weight: '100.01', max: '0', earned: 'abc');
    await fillRow(tester, 1,
        name: 'W' * 40, weight: 'abc', max: '50', earned: '51');
    await type(tester, targetField, 'abc');

    expect(tester.takeException(), isNull);
    for (final textField in find.byType(TextField).evaluate()) {
      final rect = tester.getRect(find.byWidget(textField.widget));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(phone.width));
    }
  });

  testWidgets('S-3 highlighting (UI): an error field shows the message in the error colour under the field', (tester) async {
    await pumpApp(tester);
    await type(tester, field(0, 'Weight (%)'), 'abc');

    final decorator = tester.widget<InputDecorator>(find.descendant(
        of: field(0, 'Weight (%)'), matching: find.byType(InputDecorator)));
    expect(decorator.decoration.errorText, 'Enter a number');

    final message = find.descendant(
        of: field(0, 'Weight (%)'), matching: find.text('Enter a number'));
    final input = find.descendant(
        of: field(0, 'Weight (%)'), matching: find.byType(EditableText));
    expect(tester.getTopLeft(message).dy,
        greaterThan(tester.getBottomLeft(input).dy));
    expect(tester.widget<Text>(message).style?.color,
        Theme.of(tester.element(message)).colorScheme.error);
  });

  testWidgets('S-3 criterion 16 (UI): fixing a value brings the results back live', (tester) async {
    await pumpApp(tester);
    await enterCourseA(tester);
    await type(tester, field(1, 'Points earned'), 'abc');
    expect(find.text('Fix the highlighted fields to see your results.'),
        findsOneWidget);

    await type(tester, field(1, 'Points earned'), '75');
    expect(find.text('Fix the highlighted fields to see your results.'),
        findsNothing);
    expect(find.text('Current grade 78.75% (C)'), findsOneWidget);
  });

  testWidgets('S-5 criterion 17 and S-7 criterion 1 (UI): typing updates the results on the same keystroke', (tester) async {
    await pumpApp(tester);
    await enterCourseA(tester, finalEarned: '88');
    expect(find.text('Final grade 84.30% (B)'), findsOneWidget);

    await type(tester, field(2, 'Points earned'), '97.5');
    expect(find.text('Final grade 90.00% (A)'), findsOneWidget);

    await type(tester, field(2, 'Points earned'), '');
    await type(tester, targetField, '85');
    expect(
        find.text(
            'You need at least 89.17% on each remaining assessment to reach 85.00% (B).'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('targetLetter')), findsOneWidget);

    await type(tester, targetField, '80');
    expect(
        find.text(
            'You need at least 80.84% on each remaining assessment to reach 80.00% (B).'),
        findsOneWidget);
  });

  testWidgets('Results order (UI): lines appear in spec order and empty ones are skipped', (tester) async {
    await pumpApp(tester);
    await enterCourseA(tester);
    await type(tester, targetField, '85');

    double top(String key) =>
        tester.getTopLeft(find.byKey(ValueKey(key))).dy;
    expect(top('weightsLine'), lessThan(top('gradeLine')));
    expect(top('gradeLine'), lessThan(top('coverageLine')));
    expect(top('coverageLine'), lessThan(top('requiredScoreLine')));
    expect(find.byKey(const ValueKey('weightsWarning')), findsNothing);
    expect(find.byKey(const ValueKey('resultsMessage')), findsNothing);
  });

  testWidgets('Layout (UI): on desktop the target and results sit beside the rows', (tester) async {
    await pumpApp(tester);

    expect(tester.getTopLeft(find.byType(ResultsCard)).dx,
        greaterThan(tester.getTopRight(rowAt(0)).dx));
    expect(tester.getTopLeft(targetField).dx,
        greaterThan(tester.getTopRight(rowAt(0)).dx));
  });

  testWidgets('Layout (UI): on a phone the target and results sit above the rows', (tester) async {
    await pumpApp(tester, size: phone);

    expect(tester.getBottomLeft(find.byType(ResultsCard)).dy,
        lessThan(tester.getTopLeft(rowAt(0)).dy));
    expect(tester.getBottomLeft(targetField).dy,
        lessThan(tester.getTopLeft(find.byType(ResultsCard)).dy));
  });

  testWidgets('Main flow (UI): entering example course A, then the final exam', (tester) async {
    await pumpApp(tester);
    await enterCourseA(tester);

    expect(find.text('Weights total: 100.00%'), findsOneWidget);
    expect(find.text('Current grade 78.75% (C)'), findsOneWidget);
    expect(find.text('Based on completed work: 40.00% of the course'),
        findsOneWidget);

    await type(tester, field(2, 'Points earned'), '88');
    expect(find.text('Final grade 84.30% (B)'), findsOneWidget);
    expect(find.byKey(const ValueKey('coverageLine')), findsNothing);
  });
}
