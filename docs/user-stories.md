# User Stories with Acceptance Criteria

## Traceability

| Role | Job | Stories |
|---|---|---|
| Student | J-1: understand how results so far add up | S-1, S-2, S-3, S-10, S-11 |
| Student | J-2: know how well I must do on what's left | S-5 |
| Instructor | J-3: work out a correct, justifiable final grade | S-4, S-6, S-8, S-9, S-12 |
| Instructor | J-4: see how a changed mark affects the result | S-7 |

## Assumptions

- One screen serves both Students and Instructors. There is no role switch.
- The app supports the latest desktop versions of Chrome, Edge, Firefox and Safari. The versions tested are listed in the README.
- The required score is a percentage of each remaining assessment's max points. It is never converted to points.
- Out of scope: screen-reader announcements when results change. This is listed in the README as a known limitation.

## Screen elements

The criteria refer to these elements by name.

- **Assessment row**: Name, Weight (%), Max points and Points earned fields, and a **Remove** button.
- **Add assessment** button, and the **row limit message** shown with it.
- **Target grade** field, and the **target letter** shown next to it.
- **Results area**, which contains:
  - **weights line**: "Weights total: X%"
  - **weights warning**: "Weights must total exactly 100%."
  - **grade line**: "Current grade X% (L)" or "Final grade X% (L)"
  - **coverage line**: "Based on completed work: X% of the course"
  - **required score line**
  - **results message**: "Add your assessments to see your grade.", "Enter points earned for at least one assessment to see your current grade." or "Fix the highlighted fields to see your results."

## Rules used in these criteria

### Calculation
- **Grade** = sum of (weight × points earned ÷ max points) ÷ sum of weights, over marked assessments only, shown as a percentage.
- The **"at least" grade** is the grade over all assessments if every remaining assessment scores 0%. The **highest reachable grade** is the grade over all assessments if every remaining assessment scores 100%.
- All arithmetic is exact rational arithmetic, and values are rounded only when displayed. So 33.33 + 33.33 + 33.34 equals exactly 100, and 89.995 is never stored as 89.99499….
- Decisions use exact values, never displayed ones: whether the weights total 100, whether a target is achievable, and whether it is already secured.

### Display
- Grades are shown to 2 decimal places, rounded half up (89.995 shows as 90.00).
- The **required score** is rounded **up**, so reaching it always reaches the target.
- The "at least" grade and the highest reachable grade are rounded **down**, so both statements are always true.
- The letter comes from the value shown: A ≥ 90.00, B ≥ 80.00, C ≥ 70.00, D ≥ 60.00, F below 60.00.
- Every displayed number has 2 decimal places and uses a comma as the thousands separator, such as 2,000.00%.
- Values typed in these criteria are written without commas: type 10000, not 10,000.

### Input
- **Limits:** weight more than 0 and at most 100; max points more than 0 and at most 10,000; points earned from 0 to max points; target from 0 to 100; at most 2 decimal places in any number field; up to 20 rows on screen, blank or not.
- **Valid numbers:** spaces and other whitespace around a value are trimmed, and a field containing only whitespace is blank. A plain decimal number is accepted, with an optional + or - sign, leading zeros, and nothing required before or after the decimal point: "007", ".5", "5." and "+5" are all valid, and "-0" is 0. Anything else shows "Enter a number", including "1e3", "0x10", "NaN", "Infinity", "85,5", "1,000", and ".", "+" or "-" on its own.
- Decimal places are counted as typed, so "5.000" shows "Use at most 2 decimal places".
- **Name** is plain text with no number rules. It holds at most 40 characters: typing stops at 40 and a character counter is shown, which is not an error. An emoji counts as one character.
- A **row is in use** when any of its fields, including Name, is not blank. A row that is not in use is ignored.
- Every row in use needs a Weight. Max points is needed only once Points earned is filled in, so a row with only a Weight is a valid upcoming assessment.
- A blank **Points earned** means the assessment has not been marked yet.

### Messages
- Each field shows one message at a time, checked in this order: "Enter a number", then "Use at most 2 decimal places", then the range message, then the message that compares it with another field.
- Points earned is checked again whenever Max points changes. If Max points is invalid, Points earned skips the "cannot be more than max points" check but still shows its own number or decimal places error.
- Every invalid Target grade shows "Target must be a number from 0 to 100", whether it is not a number, has too many decimal places or is out of range.
- A field with an error is **highlighted**: it has a red border and the error text is shown under it.
- Results recalculate on every keystroke. A message such as "Enter a weight" can appear while a row is still being typed, and it disappears once the field is filled in.

### Results area order
1. If any assessment field has an error, the results area shows only the results message "Fix the highlighted fields to see your results." No weights line, grade, letter, coverage line or required score is shown, including any value calculated before the error. The target letter stays.
2. Otherwise, once any row is in use, the weights line is shown, followed by the weights warning if the weights do not total exactly 100. The warning is not an error.
3. Then the grade line, or a results message if there is no grade. The coverage line follows only when a grade is shown, the weights total 100 and at least one row in use is unmarked.
4. Then the required score line:
   - Target grade blank, or no row in use: nothing is shown.
   - Weights not totalling 100 and Target grade filled in, valid or not: "Required score is shown once weights total 100%." This wins over "No remaining assessments, so no required score."
   - A Target grade error hides only the required score and the target letter. The grade line stays.

### Layout
- The app works in a window 375 px wide with no sideways scrolling.

**Example course A**, used in several criteria:

| Assessment | Weight | Max points | Points earned |
|---|---|---|---|
| Quiz | 10 | 20 | 18 |
| Midterm | 30 | 100 | 75 |
| Final exam | 60 | 100 | *(blank)* |

---

## Planned stories

### S-1 (serves J-1, Status: Planned)
"As a Student, I want to list each assessment in my course with its weight, maximum points and the points I earned, leaving upcoming ones blank, so that my grade is worked out from my actual course structure."

- Given I open the app, then I see one assessment row with empty Name, Weight (%), Max points and Points earned fields, the results message "Add your assessments to see your grade." and no weights line.
- Given one row, when I select Add assessment, then a second empty row appears below it.
- Given two filled rows, when I select Remove on the first row, then only the second row remains with its values unchanged, and the results area updates.
- Given only one row, then its Remove button is disabled.
- Given 20 rows, then Add assessment is disabled and the row limit message shows "You can add up to 20 assessments."
- Given 20 rows, when I select Remove on any row, then Add assessment is enabled again and the row limit message disappears.
- Given a row with valid numbers and a blank Name, then results are calculated as normal.
- Given a row where every field is blank, then it is not in use and is ignored, and results are calculated from the other rows.
- Given a row where only Name is filled in, then the Weight field shows "Enter a weight".
- Given a row where only Weight is filled in, with 100, then no field shows an error and the results message shows "Enter points earned for at least one assessment to see your current grade."
- Given I type 41 characters in Name, then only the first 40 are kept and a character counter is shown, with no error.
- Given a window 375 px wide, then every field, button and the results area can be used without sideways scrolling.

### S-2 (serves J-1, Status: Planned)
"As a Student, I want to see my current grade on the work marked so far, as a percentage and a letter, so that I know how my results add up despite their different weights."

- Given example course A, then the grade line shows "Current grade 78.75% (C)" and the coverage line shows "Based on completed work: 40.00% of the course".
- Given every row in use has Points earned blank, then no grade line or coverage line is shown, and the results message shows "Enter points earned for at least one assessment to see your current grade."
- Given one assessment with weight 100, max points 100 and points earned 79.99, then the grade line shows 79.99% (C); when I change points earned to 80, then it shows 80.00% (B).
- Given one assessment with weight 100, max points 200 and points earned 179.99, then the grade line shows 90.00% (A).
- Given every marked assessment has 0 points earned, then the grade line shows 0.00% (F) and no error.
- Given one assessment with weight 100, max points 10000 and points earned 10000, then the grade line shows 100.00% (A).

### S-3 (serves J-1, Status: Planned)
"As a Student, I want a clear message when something I typed can't be used, so that I can fix it instead of getting a wrong grade."

- Given I type "abc", "1,000", "1e3", "0x10", "85,5", "NaN" or "Infinity" in Weight, Max points or Points earned, then that field shows "Enter a number" and the results message shows "Fix the highlighted fields to see your results."
- Given I type " 85 ", "007", ".5", "5." or "+5" in Weight, Max points or Points earned, then it is accepted as that number with no error.
- Given I type "-0" in Points earned, then it counts as 0 with no error.
- Given a field contains only spaces, then it is treated as blank.
- Given I type a value with more than 2 decimal places, such as 0.001 or 5.000, then the field shows "Use at most 2 decimal places".
- Given I enter max points 0, then the field shows "Max points must be more than 0 and at most 10,000" and no grade is shown.
- Given I enter max points 10000.01 or 1000000000, then the field shows "Max points must be more than 0 and at most 10,000".
- Given I enter weight 0 or 100.01, then the field shows "Weight must be more than 0 and at most 100".
- Given I enter points earned -5, then the field shows "Points earned cannot be negative".
- Given max points 50, when I enter points earned 51, then the field shows "Points earned cannot be more than max points".
- Given max points 100 and points earned 75, when I change Max points to 50, then Points earned shows "Points earned cannot be more than max points"; when I change Max points back to 100, then the message disappears.
- Given points earned 75, when I change Max points to 0, then only Max points shows an error.
- Given max points 0 and points earned "abc", then Max points shows "Max points must be more than 0 and at most 10,000" and Points earned shows "Enter a number".
- Given a row in use with Weight blank, then the Weight field shows "Enter a weight". Given a row with Points earned filled in and Max points blank, then the Max points field shows "Enter max points".
- Given any assessment field shows an error, then the results area shows only "Fix the highlighted fields to see your results.": no weights line, grade, letter, coverage line or required score, including any value calculated before the error. The target letter stays.
- Given a field shows an error, when I correct the value, then the message disappears and the results reappear without reloading the page.
- Given the only error is in one row, when I select Remove on that row, then the error disappears and the results reappear.

### S-4 (serves J-3, Status: Planned)
"As an Instructor, I want to see the total of the weights and be warned when it isn't exactly 100%, so that a typing mistake in the course breakdown can't produce a wrong grade."

- Given weights 10, 30 and 60, then the weights line shows "Weights total: 100.00%" and no weights warning is shown.
- Given weights 33.33, 33.33 and 33.34, then the weights line shows "Weights total: 100.00%" and no weights warning is shown.
- Given weights 0.1, 0.2 and 99.7, then the weights line shows "Weights total: 100.00%" and no weights warning is shown.
- Given weights 10, 30 and 55, with the first two marked as in example course A and Target grade 85, then the weights line shows "Weights total: 95.00%", the weights warning shows "Weights must total exactly 100%.", the grade line shows "Current grade 78.75% (C)", no coverage line is shown, the required score line shows "Required score is shown once weights total 100%.", and no result is labelled "Final grade".
- Given weights totalling 100.01, then the weights line shows "Weights total: 100.01%" and the weights warning is shown.
- Given one row with only Weight 10 filled in, then the weights line shows "Weights total: 10.00%" and the weights warning is shown.
- Given the weights warning is shown, when I correct a weight so the total is 100, then the warning disappears and the results update.

### S-5 (serves J-2, Status: Planned)
"As a Student, I want to set a target grade and see the percentage I need on each remaining assessment, so that I can plan my study effort or change my goal."

- Given I type 85 in Target grade, then the target letter shows "(B)".
- Given example course A, when I set the target to 85, then the required score line shows "You need at least 89.17% on each remaining assessment to reach 85.00% (B)."
- Given example course A, when I set the target to 80, then the required score line shows "You need at least 80.84% on each remaining assessment to reach 80.00% (B)." (80.833… is rounded up, never down.)
- Given example course A, when I set the target to 95, then the required score line shows "Not achievable: you would need 105.84% on each remaining assessment. The highest you can reach is 91.50% (A)." and no "You need at least" message.
- Given one assessment with weight 99.99 and 0 out of 100 and a second with weight 0.01 unmarked, when I set the target to 50, then the required score line shows "Not achievable: you would need 500,000.00% on each remaining assessment. The highest you can reach is 0.01% (F)."
- Given one assessment with weight 50 and 80 out of 100 and a second with weight 50 unmarked, when I set the target to 90, then the required score line shows "You need at least 100.00% on each remaining assessment to reach 90.00% (A)."
- Given one assessment with weight 70 and 100 out of 100 and a second with weight 30 unmarked, when I set the target to 60, then the required score line shows "Already secured: you will reach at least 70.00% (C) even with 0% on the remaining assessments."
- Given one assessment with weight 50 and 100 out of 100 and a second with weight 50 unmarked, when I set the target to 50, then the required score line shows "Already secured: you will reach at least 50.00% (F) even with 0% on the remaining assessments."
- Given one assessment with weight 90 and 9444 out of 10000 and a second with weight 10 unmarked, when I set the target to 85, then the required score line shows "You need at least 0.04% on each remaining assessment to reach 85.00% (B)." (The "at least" grade is exactly 84.996, which is below 85.)
- Given the same two assessments, when I set the target to 84, then the required score line shows "Already secured: you will reach at least 84.99% (B) even with 0% on the remaining assessments." (84.996 is rounded down, not up to 85.00.)
- Given two unmarked assessments with weights 40 and 60, when I set the target to 75, then the required score line shows "You need at least 75.00% on each remaining assessment to reach 75.00% (C)."
- Given every assessment is marked and the weights total 100, when I set a target, then the required score line shows "No remaining assessments, so no required score."
- Given every assessment is marked and the weights total 95, when I set a target, then the required score line shows "Required score is shown once weights total 100%." and not "No remaining assessments, so no required score."
- Given I type 100.01, -1, 85.555 or "abc" in Target grade, then the field shows "Target must be a number from 0 to 100", no required score or target letter is shown, and the grade line is still shown.
- Given weights totalling 95, when I type "abc" in Target grade, then the field shows "Target must be a number from 0 to 100" and the required score line shows "Required score is shown once weights total 100%."
- Given Target grade is blank, then no required score, no target letter and no error are shown.
- Given a required score is shown, when I change the target or any mark, then the required score updates on the same keystroke.
- Given no row is in use, when I type 85 in Target grade, then the target letter shows "(B)", the results message shows "Add your assessments to see your grade." and no required score is shown.

### S-6 (serves J-3, Status: Planned)
"As an Instructor, I want the result labelled Final grade only when every assessment is marked and the weights total 100%, so that I never record a partial grade as final."

- Given example course A with Final exam points earned 88, then the grade line shows "Final grade 84.30% (B)" and no coverage line is shown.
- Given example course A with Final exam points earned blank, then the grade line is labelled "Current grade", not "Final grade".
- Given every assessment is marked and the weights total 95, then the grade line is labelled "Current grade" and the weights warning is shown.
- Given weights 33.33, 33.33 and 33.34, each with max points 100 and points earned 90, 80 and 70, then the grade line shows "Final grade 80.00% (B)".
- Given any grade is shown, then the letter in the grade line matches the percentage shown, under the grade scale.
- Given one assessment with weight 100, then these points earned show these grade lines:

  | Max points | Points earned | Grade line |
  |---|---|---|
  | 100 | 0 | Final grade 0.00% (F) |
  | 100 | 59.99 | Final grade 59.99% (F) |
  | 100 | 60 | Final grade 60.00% (D) |
  | 100 | 69.99 | Final grade 69.99% (D) |
  | 100 | 70 | Final grade 70.00% (C) |
  | 100 | 79.99 | Final grade 79.99% (C) |
  | 100 | 80 | Final grade 80.00% (B) |
  | 100 | 89.99 | Final grade 89.99% (B) |
  | 100 | 90 | Final grade 90.00% (A) |
  | 100 | 100 | Final grade 100.00% (A) |
  | 10000 | 8999.4 | Final grade 89.99% (B) |
  | 10000 | 8999.5 | Final grade 90.00% (A) |

### S-7 (serves J-4, Status: Planned)
"As an Instructor, I want to change any mark and see the result update immediately, so that I can check the effect of a regrade while talking to the student."

- Given example course A with Final exam points earned 88 showing "Final grade 84.30% (B)", when I change Final exam points earned to 97.5, then the grade line shows "Final grade 90.00% (A)" on the same keystroke, without pressing any button.
- Given the same course, when I change Midterm max points to 0, then Max points shows its error, Midterm Points earned shows no error, and the results message shows "Fix the highlighted fields to see your results."; when I change it back to 100, then the grade line shows "Final grade 84.30% (B)" again.
- Given the same course, when I clear Final exam points earned, then the grade line shows "Current grade 78.75% (C)".
- Given the same course, when I remove the Quiz row, then the weights line shows "Weights total: 90.00%", the weights warning shows "Weights must total exactly 100%." and the grade line shows "Current grade 83.67% (B)".

---

## Not implemented (next steps)

### S-8 (serves J-3, Status: Not implemented)
"As an Instructor, I want to clear all marks but keep the course's assessments, weights and max points, so that I can check the next student without re-entering the course breakdown."

- Given three assessments with marks, when I select "Clear marks", then every Points earned field is blank and every Name, Weight and Max points value is unchanged.

### S-9 (serves J-3, Status: Not implemented)
"As an Instructor, I want to set my course's own grade scale, including plus and minus grades, so that the letter matches my institution's policy."

- Given a scale where B+ starts at 87.00, when a grade of 87.00% is shown, then its letter is B+.
- Given cutoffs that overlap or are out of order, when I save the scale, then I see a message and the previous scale stays in use.

### S-10 (serves J-1, Status: Not implemented)
"As a Student, I want my assessments to still be there when I come back, so that I can update my grade as new marks arrive without re-entering everything."

- Given I have entered three assessments, when I close and reopen the app in the same browser, then the same three assessments and values are shown.
- Given saved assessments, when I select "Clear saved data", then the app returns to its opening state and nothing is restored when I reopen it.

### S-11 (serves J-1, Status: Not implemented)
"As a Student, I want to include extra-credit points above an assessment's maximum, so that my grade reflects bonus marks my course allows."

- Given an assessment marked as allowing extra credit with max points 20, when I enter 22 points earned, then that assessment counts as 110% and no error is shown.

### S-12 (serves J-3, Status: Not implemented)
"As an Instructor, I want to see how much each assessment contributes to the grade, so that I can justify the result to a student."

- Given example course A with Final exam points earned 88, then each row shows its contribution to the grade: Quiz 9.00%, Midterm 22.50% and Final exam 52.80%, which add up to "Final grade 84.30% (B)".
