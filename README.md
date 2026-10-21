# Grade calculator

See where you stand in a weighted course, and what you need on the rest.

**Live app:** _not deployed yet, link added after deploy_

## What it is, who it's for, and why

Students in courses with weighted assessments often guess where they stand from individual marks that count for different amounts. Partway through a term they don't know their real grade, or how hard to work on what's left. A calculator that says a target is reachable when it would need more than 100% gives false hope.

Instructors have the opposite problem. They need an exact final grade they can justify, and a quick way to check the effect of a regrade. A partial grade must never be shown as final.

I chose this problem because it is a small calculation where a wrong answer has real consequences: poor study planning for a student, or a wrong grade on an official record. That makes the rules (exact maths, rounding, input checks) worth getting right and easy to test.

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
- **Architecture:** two guard tests that keep the grading code free of Flutter imports and floating-point maths.

To check the code for problems, run `flutter analyze`.

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
- The letter scale is fixed: A ≥ 90, B ≥ 80, C ≥ 70, D ≥ 60, F below 60. The letter always comes from the percentage shown.
- The required score is a percentage of each remaining assessment, never a number of points.
- All maths is exact. Values are rounded only for display: grades half up, required scores up, and "at least" or "highest you can reach" grades down, so every statement shown is true.
- A row counts only once a number is entered in it. A name on its own is ignored.

## Known limitations

- **Screen readers:** results are not announced when they change, and Flutter web needs its "Enable accessibility" button pressed before a screen reader can read the page.
- **Nothing is saved:** reloading the page clears everything ([S-10](docs/user-stories.md#s-10-serves-j-1-status-not-implemented)).
- **Not built yet:** custom grade scales (S-9), extra credit (S-11), "Clear marks" for the next student (S-8) and a per-assessment breakdown (S-12).
- **Decimal commas** such as "85,5" are not accepted. Use a point.
- **Phones:** the 375 px layout is covered by tests but has not been tried on a real phone.
- **Internet:** the app loads part of Flutter's web engine from Google's servers, so it needs a connection when it opens.

## How this was built

- **AI tool and model:** Claude chat and Claude Code (VS Code extension), both using **Claude Opus 5.5** (`claude-opus-5-5`).
- **Planning and docs:** I used Claude chat to plan and to draft the product docs. The decisions are mine, and I reviewed and edited the docs.
- **Code:** all code was written by Claude Code in one session. I reviewed every change before it was committed and tested the app in the browsers above.
- **Code changed by hand:** none.

## Project structure

```
docs/                  Product docs: roles, jobs to be done, user stories
src/                   Flutter web app
  lib/grading/         All grading rules, pure Dart (parsing, maths, messages)
  lib/ui/              The screen: one stateful page, a row widget, a results card
  test/grading/        One unit test per acceptance criterion, plus guard tests
  test/widget/         Widget tests for the UI-only criteria and main flows
```

## Docs

- [App roles](docs/app-roles.md): who uses the app and what they must never see
- [Jobs to be done](docs/jobs-to-be-done.md): the four jobs the app serves
- [User stories](docs/user-stories.md): stories, rules and acceptance criteria
