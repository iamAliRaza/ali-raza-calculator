import 'package:flutter_test/flutter_test.dart';
import 'package:grade_calculator/grading/grading.dart';

// Message text copied from docs/user-stories.md, not from the app code.
const addAssessmentsMessage = 'Add your assessments to see your grade.';
const enterPointsMessage =
    'Enter points earned for at least one assessment to see your current grade.';
const fixFieldsMessage = 'Fix the highlighted fields to see your results.';
const weightsWarning = 'Weights must total exactly 100%.';
const weightsNot100Message = 'Required score is shown once weights total 100%.';
const targetErrorMessage = 'Target must be a number from 0 to 100';

const blankRow = AssessmentInput();

// Example course A.
const quiz = AssessmentInput(
    name: 'Quiz', weight: '10', maxPoints: '20', pointsEarned: '18');
const midterm = AssessmentInput(
    name: 'Midterm', weight: '30', maxPoints: '100', pointsEarned: '75');

AssessmentInput finalExam([String earned = '']) => AssessmentInput(
    name: 'Final exam', weight: '60', maxPoints: '100', pointsEarned: earned);

List<AssessmentInput> courseA({String finalEarned = ''}) =>
    [quiz, midterm, finalExam(finalEarned)];

AssessmentInput row({
  String name = '',
  String weight = '',
  String max = '',
  String earned = '',
}) =>
    AssessmentInput(
        name: name, weight: weight, maxPoints: max, pointsEarned: earned);

GradeResult run(List<AssessmentInput> rows, {String target = ''}) =>
    evaluate(GradeInput(assessments: rows, target: target));

extension AssessmentInputCopy on AssessmentInput {
  AssessmentInput copyWith({
    String? name,
    String? weight,
    String? maxPoints,
    String? pointsEarned,
  }) =>
      AssessmentInput(
        name: name ?? this.name,
        weight: weight ?? this.weight,
        maxPoints: maxPoints ?? this.maxPoints,
        pointsEarned: pointsEarned ?? this.pointsEarned,
      );
}

/// The three number fields of a row: label, setter, error getter.
typedef NumberField = (
  String label,
  AssessmentInput Function(AssessmentInput, String) set,
  String? Function(AssessmentResult) error,
);

final List<NumberField> numberFields = [
  ('Weight', (a, v) => a.copyWith(weight: v), (e) => e.weightError),
  ('Max points', (a, v) => a.copyWith(maxPoints: v), (e) => e.maxPointsError),
  (
    'Points earned',
    (a, v) => a.copyWith(pointsEarned: v),
    (e) => e.pointsEarnedError
  ),
];

List<String> fieldErrors(GradeResult r) => [
      for (final a in r.assessments)
        for (final e in [a.weightError, a.maxPointsError, a.pointsEarnedError])
          ?e,
    ];

/// Results order rule 1: an assessment error leaves only the fix message.
void expectOnlyFixMessage(GradeResult r, {String? reason}) {
  expect(r.results.resultsMessage, fixFieldsMessage, reason: reason);
  expect(r.results.weightsLine, isNull, reason: reason);
  expect(r.results.weightsWarning, isNull, reason: reason);
  expect(r.results.gradeLine, isNull, reason: reason);
  expect(r.results.coverageLine, isNull, reason: reason);
  expect(r.results.requiredScoreLine, isNull, reason: reason);
}
