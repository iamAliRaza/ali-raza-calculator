/// Raw text from the screen, exactly as typed. The UI does not trim or parse.
class GradeInput {
  const GradeInput({required this.assessments, required this.target});

  /// In screen order.
  final List<AssessmentInput> assessments;
  final String target;
}

class AssessmentInput {
  const AssessmentInput({
    this.name = '',
    this.weight = '',
    this.maxPoints = '',
    this.pointsEarned = '',
  });

  final String name;
  final String weight;
  final String maxPoints;
  final String pointsEarned;
}
