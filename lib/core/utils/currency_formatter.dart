import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static String format(dynamic amount) {
    if (amount == null) return '0đ';
    final num value = amount is num ? amount : (num.tryParse(amount.toString()) ?? 0);
    return _formatter.format(value).trim();
  }
}
