import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Decimal-safe money helpers.
///
/// The API transports money as decimal strings; the app keeps them as
/// [Decimal] and never routes an authoritative value through `double`.
class MoneyUtils {
  MoneyUtils._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'PKR ',
    decimalDigits: 2,
  );

  static final NumberFormat _plain = NumberFormat('#,##0.00', 'en_PK');

  /// Parses a decimal string such as `"1500.00"`.
  static Decimal parseDecimal(String value) => Decimal.parse(value.trim());

  /// Canonical wire/format representation: always two decimal places.
  static String formatDecimal(Decimal d) => d.toStringAsFixed(2);

  /// Display form: `PKR 1,500.00`.
  static String formatPKR(Decimal d) => _currency.format(_asDouble(d));

  /// Display form without the currency symbol: `1,500.00`.
  static String formatPlain(Decimal d) => _plain.format(_asDouble(d));

  /// Compact display for tight tiles: `PKR 12.5K`, `PKR 1.2M`.
  static String formatCompactPKR(Decimal d) {
    final abs = d.abs();
    if (abs >= Decimal.fromInt(1000000)) {
      return 'PKR ${(d / Decimal.fromInt(1000000)).toDecimal(scaleOnInfinitePrecision: 1).toStringAsFixed(1)}M';
    }
    if (abs >= Decimal.fromInt(100000)) {
      return 'PKR ${(d / Decimal.fromInt(1000)).toDecimal(scaleOnInfinitePrecision: 1).toStringAsFixed(1)}K';
    }
    return formatPKR(d);
  }

  /// Kept for read-only aggregate tiles that already hold a double.
  static String formatPKRFromDouble(double d) => _currency.format(d);

  static Decimal zero() => Decimal.zero;

  static Decimal sum(Iterable<Decimal> values) =>
      values.fold<Decimal>(Decimal.zero, (a, b) => a + b);

  static double _asDouble(Decimal d) => double.parse(d.toStringAsFixed(2));
}
