/// Everything the screen shows, as exact display text. Null means not shown.
class GradeResult {
  const GradeResult({
    required this.assessments,
    required this.canAddAssessment,
    required this.canRemoveAssessment,
    required this.rowLimitMessage,
    required this.targetError,
    required this.targetLetter,
    required this.results,
  });

  /// Same order and length as the input rows.
  final List<AssessmentResult> assessments;
  final bool canAddAssessment;
  final bool canRemoveAssessment;
  final String? rowLimitMessage;
  final String? targetError;

  /// Includes the parentheses, such as "(B)".
  final String? targetLetter;
  final ResultsArea results;
}

/// Field errors for one row. A field with an error is highlighted.
class AssessmentResult {
  const AssessmentResult({
    required this.weightError,
    required this.maxPointsError,
    required this.pointsEarnedError,
  });

  final String? weightError;
  final String? maxPointsError;
  final String? pointsEarnedError;
}

/// The results area, one field per screen element, in screen order.
/// [resultsMessage] takes the grade line's place when there is no grade.
class ResultsArea {
  const ResultsArea({
    required this.weightsLine,
    required this.weightsWarning,
    required this.gradeLine,
    required this.resultsMessage,
    required this.coverageLine,
    required this.requiredScoreLine,
  });

  final String? weightsLine;
  final String? weightsWarning;
  final String? gradeLine;
  final String? resultsMessage;
  final String? coverageLine;
  final String? requiredScoreLine;
}
