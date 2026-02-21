import 'package:intl/intl.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final NumberFormat _format = NumberFormat.currency(
    locale: 'es',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String format(num value) => _format.format(value);
}

