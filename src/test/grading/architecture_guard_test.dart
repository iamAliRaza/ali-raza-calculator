import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Enforces two architecture rules on lib/grading: it is pure Dart, and its
// maths never uses floating point. Comments are ignored, so the rules can be
// described in words.
void main() {
  final sources = {
    for (final f in Directory('lib/grading')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart')))
      f.path: f
          .readAsStringSync()
          .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
          .replaceAll(RegExp(r'//[^\n]*'), ''),
  };

  test('Architecture: lib/grading has source files to check', () {
    expect(sources, isNotEmpty);
  });

  test('Architecture: lib/grading does not import Flutter', () {
    final flutterImport = RegExp(r'''import\s+['"](package:flutter/|dart:ui)''');
    for (final MapEntry(key: path, value: code) in sources.entries) {
      expect(flutterImport.hasMatch(code), isFalse, reason: path);
    }
  });

  test('Architecture: lib/grading does not use double, num or toDouble', () {
    final floatingPoint = RegExp(r'\b(double|num)\b|toDouble');
    for (final MapEntry(key: path, value: code) in sources.entries) {
      expect(floatingPoint.firstMatch(code)?.group(0), isNull, reason: path);
    }
  });
}
