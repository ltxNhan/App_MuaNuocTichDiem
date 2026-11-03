class LoyaltyLogModel {
  final int id;
  final String userId;
  final String? orderId;
  final int pointsChanged;
  final int balanceAfter;
  final String action; // 'earn', 'redeem', 'bonus', 'expire'
  final String description;
  final String createdAt;

  const LoyaltyLogModel({
    required this.id,
    required this.userId,
    this.orderId,
    required this.pointsChanged,
    required this.balanceAfter,
    required this.action,
    required this.description,
    required this.createdAt,
  });

  factory LoyaltyLogModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyLogModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      userId: json['user_id']?.toString() ?? '',
      orderId: json['order_id']?.toString(),
      pointsChanged: (json['points_changed'] is num) ? (json['points_changed'] as num).toInt() : 0,
      balanceAfter: (json['balance_after'] is num) ? (json['balance_after'] as num).toInt() : 0,
      action: json['action']?.toString() ?? 'earn',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
