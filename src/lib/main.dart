import 'package:flutter/material.dart';

import 'ui/grade_calculator_page.dart';

void main() {
  runApp(const GradeCalculatorApp());
}

class GradeCalculatorApp extends StatelessWidget {
  const GradeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const GradeCalculatorPage(),
    );
  }
}
