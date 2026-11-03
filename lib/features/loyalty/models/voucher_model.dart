class VoucherModel {
  final int id;
  final String code;
  final String title;
  final String discountType; // 'percent' | 'fixed'
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscount;
  final int pointsRequired;
  final int quantity;
  final String expiredAt;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    this.maxDiscount,
    required this.pointsRequired,
    required this.quantity,
    required this.expiredAt,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Voucher ưu đãi',
      discountType: json['discount_type']?.toString() ?? 'percent',
      discountValue: (json['discount_value'] is num)
          ? (json['discount_value'] as num).toDouble()
          : (double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0),
      minOrderValue: (json['min_order_value'] is num)
          ? (json['min_order_value'] as num).toDouble()
          : (double.tryParse(json['min_order_value']?.toString() ?? '0') ?? 0.0),
      maxDiscount: (json['max_discount'] is num)
          ? (json['max_discount'] as num).toDouble()
          : (json['max_discount'] != null ? double.tryParse(json['max_discount'].toString()) : null),
      pointsRequired: (json['points_required'] is num) ? (json['points_required'] as num).toInt() : 0,
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 100,
      expiredAt: json['expired_at']?.toString() ?? '2026-12-31',
    );
  }
}
