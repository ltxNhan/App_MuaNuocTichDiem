class VietQrModel {
  final String bankId;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final double amount;
  final String memo;
  final String qrQuickLink;

  const VietQrModel({
    required this.bankId,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.memo,
    required this.qrQuickLink,
  });

  factory VietQrModel.fromJson(Map<String, dynamic> json) {
    return VietQrModel(
      bankId: json['bank_id']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0),
      memo: json['memo']?.toString() ?? '',
      qrQuickLink: json['qr_quick_link']?.toString() ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String orderCode;
  final String orderType; // 'pickup' | 'delivery'
  final String? pickupTime;
  final String? deliveryAddress;
  final String recipientPhone;
  final String recipientName;
  final double subtotalAmount;
  final double shippingFee;
  final double discountAmount;
  final double finalAmount;
  final int pointsEarned;
  final int pointsUsed;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? note;
  final String createdAt;

  const OrderModel({
    required this.id,
    required this.orderCode,
    required this.orderType,
    this.pickupTime,
    this.deliveryAddress,
    required this.recipientPhone,
    required this.recipientName,
    required this.subtotalAmount,
    required this.shippingFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.pointsEarned,
    required this.pointsUsed,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.note,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderCode: json['order_code']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? 'pickup',
      pickupTime: json['pickup_time']?.toString(),
      deliveryAddress: json['delivery_address']?.toString(),
      recipientPhone: json['recipient_phone']?.toString() ?? '',
      recipientName: json['recipient_name']?.toString() ?? '',
      subtotalAmount: (json['subtotal_amount'] is num)
          ? (json['subtotal_amount'] as num).toDouble()
          : (double.tryParse(json['subtotal_amount']?.toString() ?? '0') ?? 0.0),
      shippingFee: (json['shipping_fee'] is num)
          ? (json['shipping_fee'] as num).toDouble()
          : (double.tryParse(json['shipping_fee']?.toString() ?? '0') ?? 0.0),
      discountAmount: (json['discount_amount'] is num)
          ? (json['discount_amount'] as num).toDouble()
          : (double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0),
      finalAmount: (json['final_amount'] is num)
          ? (json['final_amount'] as num).toDouble()
          : (double.tryParse(json['final_amount']?.toString() ?? '0') ?? 0.0),
      pointsEarned: (json['points_earned'] is num) ? (json['points_earned'] as num).toInt() : 0,
      pointsUsed: (json['points_used'] is num) ? (json['points_used'] as num).toInt() : 0,
      paymentMethod: json['payment_method']?.toString() ?? 'vietqr',
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      orderStatus: json['order_status']?.toString() ?? 'pending',
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
