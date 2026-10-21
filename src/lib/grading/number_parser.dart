import 'package:decimal/decimal.dart';

/// What a number field's text means. See "Valid numbers" in the spec.
sealed class ParsedNumber {
  const ParsedNumber();
}

class Blank extends ParsedNumber {
  const Blank();
}

class NotANumber extends ParsedNumber {
  const NotANumber();
}

class TooManyDecimals extends ParsedNumber {
  const TooManyDecimals();
}

class Valid extends ParsedNumber {
  const Valid(this.value);

  final Decimal value;
}

/// Sign, whole digits, optional point with fraction digits. Both digit groups
/// may be empty here; "." or "+" on its own is rejected below.
final _plainDecimal = RegExp(r'^([+-]?)(\d*)(?:\.(\d*))?$');

ParsedNumber parseNumber(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const Blank();

  final match = _plainDecimal.firstMatch(trimmed);
  if (match == null) return const NotANumber();

  final sign = match[1]!;
  final whole = match[2]!;
  final fraction = match[3] ?? '';
  if (whole.isEmpty && fraction.isEmpty) return const NotANumber();

  // Counted as typed, so "5.000" is rejected even though it equals 5.
  if (fraction.length > 2) return const TooManyDecimals();

  // Rebuilt in a plain form so Decimal.parse never sees "+5", ".5" or "5.".
  final normalized = '${sign == '-' ? '-' : ''}'
      '${whole.isEmpty ? '0' : whole}'
      '${fraction.isEmpty ? '' : '.$fraction'}';
  return Valid(Decimal.parse(normalized));
}
