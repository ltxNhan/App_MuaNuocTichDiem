class ToppingModel {
  final int id;
  final String name;
  final double price;
  final bool isAvailable;

  const ToppingModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
  });

  factory ToppingModel.fromJson(Map<String, dynamic> json) {
    return ToppingModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
    );
  }
}
