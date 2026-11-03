import '../../menu/models/topping_model.dart';

class CartItemModel {
  final int productId;
  final String productName;
  final String imageUrl;
  final String sizeName; // 'S', 'M', 'L'
  final String sugarLevel; // '0%', '30%', '50%', '70%', '100%'
  final String iceLevel; // '0%', '50%', '100%'
  int quantity;
  final double unitPrice; // includes product base + extra size
  final List<ToppingModel> selectedToppings;
  final String? itemNote;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.sizeName,
    required this.sugarLevel,
    required this.iceLevel,
    this.quantity = 1,
    required this.unitPrice,
    this.selectedToppings = const [],
    this.itemNote,
  });

  double get toppingsTotal {
    return selectedToppings.fold(0.0, (sum, t) => sum + t.price);
  }

  double get singleItemTotal => unitPrice + toppingsTotal;

  double get totalPrice => singleItemTotal * quantity;

  Map<String, dynamic> toApiJson() {
    return {
      'product_id': productId,
      'size_name': sizeName,
      'sugar_level': sugarLevel,
      'ice_level': iceLevel,
      'quantity': quantity,
      'topping_ids': selectedToppings.map((t) => t.id).toList(),
      'item_note': itemNote,
    };
  }

  String get customizationSummary {
    final parts = <String>[];
    parts.add('Size $sizeName');
    parts.add('$sugarLevel đường');
    parts.add('$iceLevel đá');
    if (selectedToppings.isNotEmpty) {
      parts.add(selectedToppings.map((t) => t.name).join(', '));
    }
    return parts.join(' • ');
  }
}
