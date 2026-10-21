import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

final _hundred = Rational.fromInt(100);

/// An exact value rounded to 2 decimal places for display. The letter comes
/// from the rounded value, so it always matches the number shown.
class Shown {
  Shown.halfUp(Rational value) : _hundredths = (value * _hundred).round();
  Shown.up(Rational value) : _hundredths = (value * _hundred).ceil();
  Shown.down(Rational value) : _hundredths = (value * _hundred).floor();

  /// For values that already have at most 2 decimal places.
  Shown.exact(Decimal value) : this.halfUp(value.toRational());

  final BigInt _hundredths;

  /// Such as "2,000.00".
  String get text {
    final sign = _hundredths.isNegative ? '-' : '';
    final digits = _hundredths.abs().toString().padLeft(3, '0');
    final whole = digits.substring(0, digits.length - 2);
    final cents = digits.substring(digits.length - 2);
    final grouped = whole.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+$)'), (_) => ',');
    return '$sign$grouped.$cents';
  }

  String get letter {
    if (_hundredths >= BigInt.from(9000)) return 'A';
    if (_hundredths >= BigInt.from(8000)) return 'B';
    if (_hundredths >= BigInt.from(7000)) return 'C';
    if (_hundredths >= BigInt.from(6000)) return 'D';
    return 'F';
  }

  /// Such as "85.00% (B)".
  String get percentWithLetter => '$text% ($letter)';
}
