/// Grading rules for the calculator.
///
/// Pure Dart: nothing in lib/grading may import Flutter, so every rule can be
/// unit tested on its own. All arithmetic uses the decimal package, never
/// double.
library;

import 'grade_input.dart';
import 'grade_result.dart';

export 'grade_input.dart';
export 'grade_result.dart';

/// Works out everything the screen shows from the raw field text.
/// Pure, and never throws, whatever the strings or row count.
GradeResult evaluate(GradeInput input) {
  throw UnimplementedError();
}
