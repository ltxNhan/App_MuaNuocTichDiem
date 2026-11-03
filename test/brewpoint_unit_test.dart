import 'package:flutter_test/flutter_test.dart';
import 'package:dailycup/core/utils/currency_formatter.dart';
import 'package:dailycup/features/auth/models/user_model.dart';
import 'package:dailycup/features/menu/models/topping_model.dart';
import 'package:dailycup/features/cart_checkout/models/cart_item_model.dart';

void main() {
  group('BrewPoint F&B System - Unit Tests', () {
    test('CurrencyFormatter formats Vietnamese Dong correctly', () {
      expect(CurrencyFormatter.format(45000), '45.000\u{00A0}đ');
      expect(CurrencyFormatter.format(12500000), '12.500.000\u{00A0}đ');
    });

    test('UserModel JSON deserialization and fields', () {
      final json = {
        'id': 'usr_gold_001',
        'phone': '0901234567',
        'email': 'nguyenvana@brewpoint.vn',
        'full_name': 'Nguyễn Văn An',
        'points': 350,
        'membership_tier': 'Gold',
        'total_spent': 4200000.0,
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'usr_gold_001');
      expect(user.phone, '0901234567');
      expect(user.points, 350);
      expect(user.membershipTier, 'Gold');
      expect(user.totalSpent, 4200000.0);
    });

    test('Drink Customization & Cart Pricing Calculation', () {
      // Base: 45.000đ, Size L: +12.000đ, Toppings: Trân châu đen 10.000đ + Kem Cheese 15.000đ
      // Single cup = 45k + 12k + 10k + 15k = 82.000đ
      // Quantity = 2 => Total = 164.000đ
      final item = CartItemModel(
        productId: 1,
        productName: 'Trà Sữa Hoàng Gia',
        imageUrl: '',
        sizeName: 'L',
        sugarLevel: '50%',
        iceLevel: '70%',
        quantity: 2,
        unitPrice: 57000.0, // 45k base + 12k size L
        selectedToppings: const [
          ToppingModel(
            id: 1,
            name: 'Trân châu đen',
            price: 10000,
            isAvailable: true,
          ),
          ToppingModel(
            id: 3,
            name: 'Kem Cheese',
            price: 15000,
            isAvailable: true,
          ),
        ],
      );

      expect(item.toppingsTotal, 25000.0);
      expect(item.singleItemTotal, 82000.0);
      expect(item.totalPrice, 164000.0);
      expect(
        item.customizationSummary,
        'Size L • 50% đường • 70% đá • Trân châu đen, Kem Cheese',
      );
    });

    test('Loyalty Points Earning & Redemption Business Logic', () {
      // 10.000đ = 1 point earned
      const double orderAmount = 164000.0;
      final int pointsEarned = (orderAmount / 10000).floor();
      expect(pointsEarned, 16);

      // 1 point = 1.000đ reduction
      const int pointsUsed = 30;
      const double pointsDiscount = pointsUsed * 1000.0;
      expect(pointsDiscount, 30000.0);

      const double finalAfterDiscount = orderAmount - pointsDiscount;
      expect(finalAfterDiscount, 134000.0);
    });
  });
}
