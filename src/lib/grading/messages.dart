// Every piece of text the grading result can contain, worded exactly as in
// docs/user-stories.md.

import 'format.dart';

const enterANumber = 'Enter a number';
const tooManyDecimals = 'Use at most 2 decimal places';
const enterAWeight = 'Enter a weight';
const enterMaxPoints = 'Enter max points';
const weightOutOfRange = 'Weight must be more than 0 and at most 100';
const maxPointsOutOfRange =
    'Max points must be more than 0 and at most 10,000';
const pointsEarnedNegative = 'Points earned cannot be negative';
const pointsEarnedAboveMax = 'Points earned cannot be more than max points';
const targetInvalid = 'Target must be a number from 0 to 100';

const rowLimit = 'You can add up to 20 assessments.';

const addAssessments = 'Add your assessments to see your grade.';
const enterPointsEarned =
    'Enter points earned for at least one assessment to see your current grade.';
const fixHighlightedFields = 'Fix the highlighted fields to see your results.';

String weightsTotal(Shown total) => 'Weights total: ${total.text}%';
const weightsMustTotal100 = 'Weights must total exactly 100%.';

String gradeLine(Shown grade, {required bool isFinal}) =>
    '${isFinal ? 'Final' : 'Current'} grade ${grade.percentWithLetter}';
String coverage(Shown markedWeight) =>
    'Based on completed work: ${markedWeight.text}% of the course';
String targetLetter(Shown target) => '(${target.letter})';

String needAtLeast(Shown required, Shown target) =>
    'You need at least ${required.text}% on each remaining assessment '
    'to reach ${target.percentWithLetter}.';
String notAchievable(Shown required, Shown highest) =>
    'Not achievable: you would need ${required.text}% on each remaining '
    'assessment. The highest you can reach is ${highest.percentWithLetter}.';
String alreadySecured(Shown atLeast) =>
    'Already secured: you will reach at least ${atLeast.percentWithLetter} '
    'even with 0% on the remaining assessments.';

const requiredNeedsWeights100 =
    'Required score is shown once weights total 100%.';
const noRemainingAssessments =
    'No remaining assessments, so no required score.';
