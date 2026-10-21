# User Stories with Acceptance Criteria

## Traceability

| Role | Job | Stories |
|---|---|---|
| Student | J-1: understand how results so far add up | S-1, S-2, S-3, S-10 |
| Student | J-2: know how well I must do on what's left | S-5, S-11 |
| Instructor | J-3: work out a correct, justifiable final grade | S-4, S-6, S-8, S-9 |
| Instructor | J-4: see how a changed mark affects the result | S-7 |

## Rules used in these criteria

- **Grade** = sum of (weight × points earned ÷ max points) ÷ sum of weights, over marked assessments only, shown as a percentage.
- **Display:** grades are shown to 2 decimal places, rounded half up (89.995 shows as 90.00). The letter comes from the value shown: A ≥ 90.00, B ≥ 80.00, C ≥ 70.00, D ≥ 60.00, F below 60.00.
- **Required score** is rounded **up** to 2 decimal places, so reaching it always reaches the target.
- **Limits:** weight more than 0 and at most 100; max points more than 0 and at most 10,000; points earned from 0 to max points; target from 0 to 100; at most 2 decimal places in any field; up to 20 assessments.
- A blank **Points earned** means the assessment has not been marked yet. A row with **every** field blank is ignored.
- All arithmetic is exact decimal arithmetic, so 33.33 + 33.33 + 33.34 equals exactly 100.

**Example course A**, used in several criteria:

| Assessment | Weight | Max points | Points earned |
|---|---|---|---|
| Quiz | 10 | 20 | 18 |
| Midterm | 30 | 100 | 75 |
| Final exam | 60 | 100 | *(blank)* |

---

## S-1 (serves J-1, Status: Planned)
"As a Student, I want to list each assessment in my course with its weight, maximum points and the points I earned, leaving upcoming ones blank, so that my grade is worked out from my actual course structure."

- Given I open the app, then I see one assessment row with empty Name, Weight (%), Max points and Points earned fields, and the results area shows "Add your assessments to see your grade."
- Given one row, when I select "Add assessment", then a second empty row appears below it.
- Given two filled rows, when I select Remove on the first row, then only the second row remains with its values unchanged, and the results update.
- Given only one row, then its Remove control is disabled.
- Given 20 rows, then "Add assessment" is disabled and I see "You can add up to 20 assessments."
- Given a row with valid numbers and a blank Name, then results are calculated as normal.
- Given a row where every field is blank, then it is ignored and results are calculated from the other rows.

## S-2 (serves J-1, Status: Planned)
"As a Student, I want to see my current grade on the work marked so far, as a percentage and a letter, so that I know how my results add up despite their different weights."

- Given example course A, then I see "Current grade 78.75% (C)" and "Based on completed work: 40.00% of the course".
- Given every row has Points earned blank, then no grade is shown and I see "Enter points earned for at least one assessment to see your current grade."
- Given one assessment with weight 100, max points 100 and points earned 79.99, then I see 79.99% (C); when I change points earned to 80, then I see 80.00% (B).
- Given one assessment with weight 100, max points 200 and points earned 179.99, then I see 90.00% (A).
- Given every marked assessment has 0 points earned, then I see 0.00% (F) and no error.
- Given one assessment with weight 100, max points 10,000 and points earned 10,000, then I see 100.00% (A).

## S-3 (serves J-1, Status: Planned)
"As a Student, I want a clear message when something I typed can't be used, so that I can fix it instead of getting a wrong grade."

- Given I type "abc", "1,000", "1e3", "NaN" or "Infinity" in any number field, then that field shows "Enter a number" and the results area shows "Fix the highlighted fields to see your results."
- Given I type a value with more than 2 decimal places, such as 0.001, then the field shows "Use at most 2 decimal places".
- Given I enter max points 0, then the field shows "Max points must be more than 0 and at most 10,000" and no grade is shown.
- Given I enter max points 10,000.01 or 1000000000, then the field shows "Max points must be more than 0 and at most 10,000".
- Given I enter weight 0 or 100.01, then the field shows "Weight must be more than 0 and at most 100".
- Given I enter points earned -5, then the field shows "Points earned cannot be negative".
- Given max points 50, when I enter points earned 51, then the field shows "Points earned cannot be more than max points".
- Given a row with points earned filled in but Weight blank, then the Weight field shows "Enter a weight"; with Max points blank, the Max points field shows "Enter max points".
- Given any field shows an error, then no grade, letter or required score is shown anywhere, including any value calculated before the error.
- Given a field shows an error, when I correct the value, then the message disappears and the results reappear without reloading the page.

## S-4 (serves J-3, Status: Planned)
"As an Instructor, I want to see the total of the weights and be warned when it isn't exactly 100%, so that a typing mistake in the course breakdown can't produce a wrong grade."

- Given weights 10, 30 and 60, then I see "Weights total: 100.00%" and no warning.
- Given weights 33.33, 33.33 and 33.34, then I see "Weights total: 100.00%" and no warning.
- Given weights 0.1, 0.2 and 99.7, then I see "Weights total: 100.00%" and no warning.
- Given weights 10, 30 and 55 with the first two marked, then I see "Weights total 95.00%. They must total exactly 100%.", the current grade on completed work is still shown, the required score area shows "Required score is shown once weights total 100%.", and no result is labelled "Final grade".
- Given weights totalling 100.01, then I see "Weights total 100.01%. They must total exactly 100%."
- Given the weights warning is shown, when I correct a weight so the total is 100, then the warning disappears and the results update.

## S-5 (serves J-2, Status: Planned)
"As a Student, I want to set a target grade and see the percentage I need on each remaining assessment, so that I can plan my study effort or change my goal."

- Given I type 85 in Target grade, then I see "(B)" beside it.
- Given example course A, when I set the target to 85, then I see "You need at least 89.17% on each remaining assessment to reach 85.00% (B)."
- Given example course A, when I set the target to 80, then I see "You need at least 80.84% on each remaining assessment to reach 80.00% (B)." (80.833… is rounded up, never down.)
- Given example course A, when I set the target to 95, then I see "Not achievable: you would need 105.84% on each remaining assessment." and no "You need at least" message.
- Given one assessment with weight 50 and 80 out of 100 and a second with weight 50 unmarked, when I set the target to 90, then I see "You need at least 100.00% on each remaining assessment to reach 90.00% (A)."
- Given one assessment with weight 70 and 100 out of 100 and a second with weight 30 unmarked, when I set the target to 60, then I see "Already secured: you will reach at least 70.00% (C) even with 0% on the remaining assessments."
- Given one assessment with weight 50 and 100 out of 100 and a second with weight 50 unmarked, when I set the target to 50, then I see "Already secured: you will reach at least 50.00% (F) even with 0% on the remaining assessments."
- Given two unmarked assessments with weights 40 and 60, when I set the target to 75, then I see "You need at least 75.00% on each remaining assessment to reach 75.00% (C)."
- Given every assessment is marked, when I set a target, then I see "No remaining assessments, so no required score."
- Given I type 100.01, -1 or "abc" in Target grade, then the field shows "Target must be a number from 0 to 100" and no required score is shown.
- Given Target grade is blank, then no required score and no error are shown.
- Given a required score is shown, when I change the target or any mark, then the required score updates immediately.

## S-6 (serves J-3, Status: Planned)
"As an Instructor, I want the result labelled Final grade only when every assessment is marked and the weights total 100%, so that I never record a partial grade as final."

- Given example course A with Final exam points earned 88, then I see "Final grade 84.30% (B)".
- Given example course A with Final exam points earned blank, then the result is labelled "Current grade", not "Final grade".
- Given every assessment is marked and the weights total 95, then the result is labelled "Current grade" and the weights warning is shown.
- Given weights 33.33, 33.33 and 33.34, each with max points 100 and points earned 90, 80 and 70, then I see "Final grade 80.00% (B)".
- Given any grade is shown, then the letter beside it matches the percentage shown under the grade scale.

## S-7 (serves J-4, Status: Planned)
"As an Instructor, I want to change any mark and see the result update immediately, so that I can check the effect of a regrade while talking to the student."

- Given example course A with Final exam points earned 88 showing "Final grade 84.30% (B)", when I change Final exam points earned to 97.5, then I see "Final grade 90.00% (A)" without pressing any button.
- Given the same course, when I change Midterm max points to 0, then the field shows its error and no grade is shown; when I change it back to 100, then I see "Final grade 84.30% (B)" again.
- Given the same course, when I clear Final exam points earned, then I see "Current grade 78.75% (C)".
- Given the same course, when I remove the Quiz row, then I see "Weights total 90.00%. They must total exactly 100%." and "Current grade 83.67% (B)".

---

## Not implemented (next steps)

## S-8 (serves J-3, Status: Not implemented)
"As an Instructor, I want to clear all marks but keep the course's assessments, weights and max points, so that I can check the next student without re-entering the course breakdown."

- Given three assessments with marks, when I select "Clear marks", then every Points earned field is blank and every Name, Weight and Max points value is unchanged.

## S-9 (serves J-3, Status: Not implemented)
"As an Instructor, I want to set my course's own grade scale, including plus and minus grades, so that the letter matches my institution's policy."

- Given a scale where B+ starts at 87.00, when a grade of 87.00% is shown, then its letter is B+.
- Given cutoffs that overlap or are out of order, when I save the scale, then I see a message and the previous scale stays in use.

## S-10 (serves J-1, Status: Not implemented)
"As a Student, I want my assessments to still be there when I come back, so that I can update my grade as new marks arrive without re-entering everything."

- Given I have entered three assessments, when I close and reopen the app in the same browser, then the same three assessments and values are shown.

## S-11 (serves J-2, Status: Not implemented)
"As a Student, I want to include extra-credit points above an assessment's maximum, so that my grade reflects bonus marks my course allows."

- Given an assessment marked as allowing extra credit with max points 20, when I enter 22 points earned, then that assessment counts as 110% and no error is shown.
