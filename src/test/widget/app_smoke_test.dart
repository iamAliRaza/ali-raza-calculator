import 'package:flutter_test/flutter_test.dart';
import 'package:grade_calculator/main.dart';

void main() {
  testWidgets('app builds and shows its title', (tester) async {
    await tester.pumpWidget(const GradeCalculatorApp());

    expect(find.text('Grade calculator'), findsOneWidget);
  });
}
