import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AppEndpoints {
  AppEndpoints._();

  // Smart base URL: detects Android Emulator vs Desktop/iOS/Web
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/v1';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api/v1';
      }
    } catch (_) {}
    return 'http://localhost:3000/api/v1';
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';

  // Menu
  static const String categories = '/categories';
  static const String products = '/products';
  static const String toppings = '/toppings';

  // Orders
  static const String orders = '/orders';

  // Loyalty
  static const String dynamicQr = '/loyalty/dynamic-qr';
  static const String verifyQr = '/loyalty/verify-qr';
  static const String loyaltyLogs = '/loyalty/logs';
  static const String redeemVoucher = '/loyalty/redeem-voucher';

  // Vouchers
  static const String vouchers = '/vouchers';
  static const String applyVoucher = '/vouchers/apply';
}
