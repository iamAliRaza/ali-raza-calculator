# Grade calculator

See where you stand in a weighted course, and what you need on the rest.

**Live app:** <https://iamaliraza.github.io/ali-raza-calculator/>

Every push to `main` runs `flutter analyze` and `flutter test`, then deploys to GitHub Pages only if both pass ([workflow](.github/workflows/deploy.yml)).

## What it is, who it's for, and why

Students in courses with weighted assessments often guess where they stand from individual marks that count for different amounts. Partway through a term they don't know their real grade, or how hard to work on what's left. A calculator that says a target is reachable when it would need more than 100% gives false hope.

Instructors have the opposite problem. They need an exact final grade they can justify, and a quick way to check the effect of a regrade. A partial grade must never be shown as final.

I chose this problem because it is a small calculation where a wrong answer has real consequences: poor study planning for a student, or a wrong grade on an official record. That makes the rules (exact maths, rounding, input checks) worth getting right and easy to test.

### Why Flutter

The assignment asks for a browser app, so this submission is a web app. I built it with Flutter because it is my main framework, and the same code could also be built for iOS and Android later. Only the web version is part of this submission and tested.

## Prerequisites

- [Git](https://git-scm.com/downloads)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.47.7, stable channel** (includes Dart 3.13.5). Check with `flutter --version`.
- A desktop browser: Chrome, Edge, Firefox or Safari
- An internet connection, for `flutter pub get` and when the app loads

No accounts or API keys are needed.

## Install and run

Run these one at a time. They work the same in a macOS or Linux terminal and in Windows PowerShell or Command Prompt.

```
git clone https://github.com/iamAliRaza/ali-raza-calculator.git
cd ali-raza-calculator
cd src
flutter pub get
flutter run -d chrome
```

**Safari, Firefox or Edge:** from the `src` folder, run

```
flutter run -d web-server --web-port 8080
```

then open <http://localhost:8080> in the browser. Safari is macOS only.

To stop the app, press `q` in the terminal.

## Run the tests

From the `src` folder:

```
flutter test
```

This runs 84 tests:

- **Acceptance criteria:** one unit test per criterion, named "S-n criterion k" after [the user stories](docs/user-stories.md).
- **UI-only criteria:** widget tests for things only the screen can show, including the 375 px phone layout.
- **Architecture:** three guard tests that check the grading code has no Flutter imports and no floating-point maths.

To check the code for problems, run `flutter analyze`. The same checks also run on a clean Linux machine in GitHub Actions on every push.

## Tested browsers

All on macOS 26.6.2.

| Browser | Version |
|---|---|
| Chrome | 155.0.8059.85 |
| Safari | 27.0 |
| Firefox | 158.0.1 |
| Edge | 155.0.4283.62 |

## Assumptions

The full rules are in [docs/user-stories.md](docs/user-stories.md). The main ones:

- One screen serves both students and instructors. There is no role switch.
- Supported browsers are the latest desktop versions of Chrome, Edge, Firefox and Safari.
- Scores are entered as points (points earned out of max points). Points earned cannot be more than max points, so extra credit is not supported.
- Max points is needed only once points earned is entered, because students often don't know the max of a future exam.
- The letter scale is fixed: A ≥ 90, B ≥ 80, C ≥ 70, D ≥ 60, F below 60. The letter always comes from the percentage shown.
- The required score is a percentage of each remaining assessment, never a number of points.
- All maths is exact. Values are rounded only for display: grades half up, required scores up, and "at least" or "highest you can reach" grades down, so every statement shown is true.
- A row counts only once a number is entered in it. A name on its own is ignored.
- The decimal sign is a point.

## Known limitations

- **Nothing is saved:** reloading the page clears everything ([S-10](docs/user-stories.md#s-10-serves-j-1-status-not-implemented)).
- **Not built yet:** custom grade scales (S-9), extra credit (S-11), "Clear marks" for the next student (S-8) and a per-assessment breakdown (S-12).
- **Decimal commas** such as "85,5" are not accepted. Use a point.
- **Phones:** tried on an iPhone (Safari) using the live app, and in the browser's mobile view. Other phones, including Android, were not tried.
- **Internet:** the app loads part of Flutter's web engine from Google's servers, so it needs a connection when it opens.

## How this was built

- **AI tool and model:** Claude chat and Claude Code (VS Code extension), both using **Claude Opus 5.5** (`claude-opus-5-5`).
- **Planning and docs:** I used Claude chat to plan and to draft the product docs. The decisions are mine, and I reviewed and edited the docs.
- **Code:** all code was written by Claude Code in one session. I reviewed every change before it was committed and tested the app in the browsers above.
- **Code changed by hand:** none.
- **Session transcript:** the full Claude Code session, exported with its own export feature, is in [transcripts/session-01.txt](transcripts/session-01.txt).

## How I worked with Claude Code

- **Spec first.** I wrote the product docs before any code. The first thing I asked Claude Code for was a critical review of the docs. It found about 40 issues. I decided each one, and said no to some, for example showing the required score in points.
- **My architecture.** I set the main technical decisions: grading rules in pure Dart, exact decimal maths with no `double`, plain text fields with our own number parser, and one stateful page.
- **Plans before changes.** For each step I asked for a plan first and reviewed it before anything changed.
- **Tests before logic.** The unit tests were written from the acceptance criteria and committed before the grading logic, so I could check them against the docs first.
- **Things I caught and changed:**
  - It first assumed plain HTML and JavaScript. I corrected it to Flutter.
  - It tried to commit on a new branch. I kept the work on `main`.
  - The letter grade test could have used the app's own code to check itself. I asked for an independent check.
  - When I tested by hand, typing one letter in Name showed "Enter a weight" straight away. The spec allowed it, but it felt wrong to use, so I changed the rule, the docs and the tests.
  - After reviewing the UI: a white centered card, results above the rows on phones, and no dark theme, because it was not in the spec.
- **Checking by hand.** I tested the main flows in Chrome, Safari, Firefox and Edge, and on the live site.

## Project structure

```
docs/                  Product docs: roles, jobs to be done, user stories
src/                   Flutter web app
  lib/grading/         All grading rules, pure Dart (parsing, maths, messages)
  lib/ui/              The screen: one stateful page, a row widget, a results card
  test/grading/        One unit test per acceptance criterion, plus guard tests
  test/widget/         Widget tests for the UI-only criteria and main flows
transcripts/           The exported Claude Code session
```

## Docs

- [App roles](docs/app-roles.md): who uses the app and what they must never see
- [Jobs to be done](docs/jobs-to-be-done.md): the four jobs the app serves
- [User stories](docs/user-stories.md): stories, rules and acceptance criteria