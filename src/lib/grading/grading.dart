/// Grading rules for the calculator.
///
/// Pure Dart: nothing in lib/grading may import Flutter, so every rule can be
/// unit tested on its own. All arithmetic uses the decimal package, never
/// double.
library;

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import 'format.dart';
import 'grade_input.dart';
import 'grade_result.dart';
import 'messages.dart';
import 'number_parser.dart';

export 'grade_input.dart';
export 'grade_result.dart';

const _maxRows = 20;
final _weightLimit = Decimal.fromInt(100);
final _maxPointsLimit = Decimal.fromInt(10000);
final _targetLimit = Decimal.fromInt(100);

/// Works out everything the screen shows from the raw field text.
/// Pure, and never throws, whatever the strings or row count.
GradeResult evaluate(GradeInput input) {
  final rowCount = input.assessments.length;
  final checked = [for (final a in input.assessments) _checkRow(a)];
  final target = _checkTarget(input.target);
  final hasFieldError = checked.any((c) => c.hasError);

  return GradeResult(
    assessments: [for (final c in checked) c.result],
    canAddAssessment: rowCount < _maxRows,
    canRemoveAssessment: rowCount > 1,
    rowLimitMessage: rowCount >= _maxRows ? rowLimit : null,
    targetError: target.error,
    targetLetter: switch (target.value) {
      final value? => targetLetter(Shown.exact(value)),
      null => null,
    },
    results: hasFieldError
        ? const ResultsArea(
            weightsLine: null,
            weightsWarning: null,
            gradeLine: null,
            resultsMessage: fixHighlightedFields,
            coverageLine: null,
            requiredScoreLine: null,
          )
        : _results([for (final c in checked) ?c.assessment], target),
  );
}

/// A row in use whose fields are all valid. Unmarked when [earned] is null.
class _Assessment {
  const _Assessment(this.weight, this.max, this.earned);

  final Decimal weight;
  final Decimal? max;
  final Decimal? earned;
}

typedef _CheckedRow = ({
  AssessmentResult result,
  _Assessment? assessment,
  bool hasError,
});

_CheckedRow _checkRow(AssessmentInput input) {
  final inUse = [input.name, input.weight, input.maxPoints, input.pointsEarned]
      .any((text) => text.trim().isNotEmpty);
  if (!inUse) {
    return (
      result: const AssessmentResult(
          weightError: null, maxPointsError: null, pointsEarnedError: null),
      assessment: null,
      hasError: false,
    );
  }

  final weight = parseNumber(input.weight);
  final max = parseNumber(input.maxPoints);
  final earned = parseNumber(input.pointsEarned);

  final weightError = _fieldError(weight,
      missing: enterAWeight,
      range: (v) =>
          v > Decimal.zero && v <= _weightLimit ? null : weightOutOfRange);
  final maxError = _fieldError(max,
      missing: earned is Blank ? null : enterMaxPoints,
      range: (v) =>
          v > Decimal.zero && v <= _maxPointsLimit ? null : maxPointsOutOfRange);
  var earnedError = _fieldError(earned,
      missing: null,
      range: (v) => v < Decimal.zero ? pointsEarnedNegative : null);
  // Cross-field check last, and only against a valid Max points.
  if (earnedError == null &&
      maxError == null &&
      earned is Valid &&
      max is Valid &&
      earned.value > max.value) {
    earnedError = pointsEarnedAboveMax;
  }

  final hasError =
      weightError != null || maxError != null || earnedError != null;
  return (
    result: AssessmentResult(
      weightError: weightError,
      maxPointsError: maxError,
      pointsEarnedError: earnedError,
    ),
    assessment: hasError
        ? null
        : _Assessment(
            (weight as Valid).value,
            max is Valid ? max.value : null,
            earned is Valid ? earned.value : null,
          ),
    hasError: hasError,
  );
}

/// One message per field, in the spec's order: number, decimals, range.
/// [missing] is the message for a blank field, or null when blank is allowed.
String? _fieldError(
  ParsedNumber parsed, {
  required String? missing,
  required String? Function(Decimal) range,
}) =>
    switch (parsed) {
      Blank() => missing,
      NotANumber() => enterANumber,
      TooManyDecimals() => tooManyDecimals,
      Valid(:final value) => range(value),
    };

typedef _CheckedTarget = ({Decimal? value, String? error, bool isBlank});

_CheckedTarget _checkTarget(String text) {
  final parsed = parseNumber(text);
  return switch (parsed) {
    Blank() => (value: null, error: null, isBlank: true),
    Valid(:final value) when value >= Decimal.zero && value <= _targetLimit =>
      (value: value, error: null, isBlank: false),
    _ => (value: null, error: targetInvalid, isBlank: false),
  };
}

/// Results order rules 2 to 4, for rows that have no field errors.
ResultsArea _results(List<_Assessment> assessments, _CheckedTarget target) {
  if (assessments.isEmpty) {
    return const ResultsArea(
      weightsLine: null,
      weightsWarning: null,
      gradeLine: null,
      resultsMessage: addAssessments,
      coverageLine: null,
      requiredScoreLine: null,
    );
  }

  final marked = [for (final a in assessments) if (a.earned != null) a];
  final unmarked = [for (final a in assessments) if (a.earned == null) a];
  final totalWeight = _sumWeights(assessments);
  final markedWeight = _sumWeights(marked);
  final weightsAre100 = totalWeight == _weightLimit;

  // Sum of weight × points earned ÷ max points over marked rows, exactly.
  final earnedShare = marked.fold(
      Rational.zero,
      (sum, a) =>
          sum + (a.weight * a.earned!).toRational() / a.max!.toRational());

  final hasGrade = marked.isNotEmpty;
  return ResultsArea(
    weightsLine: weightsTotal(Shown.exact(totalWeight)),
    weightsWarning: weightsAre100 ? null : weightsMustTotal100,
    gradeLine: hasGrade
        ? gradeLine(
            Shown.halfUp(
                earnedShare / markedWeight.toRational() * _hundred),
            isFinal: unmarked.isEmpty && weightsAre100,
          )
        : null,
    resultsMessage: hasGrade ? null : enterPointsEarned,
    coverageLine: hasGrade && weightsAre100 && unmarked.isNotEmpty
        ? coverage(Shown.exact(markedWeight))
        : null,
    requiredScoreLine: _requiredScoreLine(
      target,
      weightsAre100: weightsAre100,
      earnedShare: earnedShare,
      remainingWeight: _sumWeights(unmarked).toRational(),
    ),
  );
}

/// Results order rule 4. All decisions use exact values; only the display
/// rounds. With weights totalling exactly 100, the earned share is itself the
/// "at least" grade.
String? _requiredScoreLine(
  _CheckedTarget target, {
  required bool weightsAre100,
  required Rational earnedShare,
  required Rational remainingWeight,
}) {
  if (target.isBlank) return null;
  if (!weightsAre100) return requiredNeedsWeights100;
  final targetValue = target.value;
  if (targetValue == null) return null;
  if (remainingWeight == Rational.zero) return noRemainingAssessments;

  final targetGrade = targetValue.toRational();
  final required = (targetGrade - earnedShare) / remainingWeight * _hundred;
  if (required <= Rational.zero) {
    return alreadySecured(Shown.down(earnedShare));
  }
  if (required > _hundred) {
    return notAchievable(
        Shown.up(required), Shown.down(earnedShare + remainingWeight));
  }
  return needAtLeast(Shown.up(required), Shown.exact(targetValue));
}

final _hundred = Rational.fromInt(100);

Decimal _sumWeights(List<_Assessment> assessments) =>
    assessments.fold(Decimal.zero, (sum, a) => sum + a.weight);
