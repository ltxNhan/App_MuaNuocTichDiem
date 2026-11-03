import 'topping_model.dart';

class ProductSizeModel {
  final int id;
  final int productId;
  final String sizeName; // 'S', 'M', 'L'
  final double extraPrice;

  const ProductSizeModel({
    required this.id,
    required this.productId,
    required this.sizeName,
    required this.extraPrice,
  });

  factory ProductSizeModel.fromJson(Map<String, dynamic> json) {
    return ProductSizeModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      productId: (json['product_id'] is num) ? (json['product_id'] as num).toInt() : 0,
      sizeName: json['size_name']?.toString() ?? 'M',
      extraPrice: (json['extra_price'] is num)
          ? (json['extra_price'] as num).toDouble()
          : (double.tryParse(json['extra_price']?.toString() ?? '0') ?? 0.0),
    );
  }
}

class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final String imageUrl;
  final bool isBestseller;
  final bool isAvailable;
  final List<ProductSizeModel> sizes;
  final List<ToppingModel> availableToppings;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    required this.imageUrl,
    required this.isBestseller,
    required this.isAvailable,
    this.sizes = const [],
    this.availableToppings = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<ProductSizeModel> sizesList = [];
    if (json['sizes'] != null && json['sizes'] is List) {
      sizesList = (json['sizes'] as List)
          .map((s) => ProductSizeModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    List<ToppingModel> toppingsList = [];
    if (json['available_toppings'] != null && json['available_toppings'] is List) {
      toppingsList = (json['available_toppings'] as List)
          .map((t) => ToppingModel.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    return ProductModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      categoryId: (json['category_id'] is num) ? (json['category_id'] as num).toInt() : 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      basePrice: (json['base_price'] is num)
          ? (json['base_price'] as num).toDouble()
          : (double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0),
      imageUrl: json['image_url']?.toString() ?? '',
      isBestseller: json['is_bestseller'] == true || json['is_bestseller'] == 1,
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      sizes: sizesList,
      availableToppings: toppingsList,
    );
  }

  ProductModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? description,
    double? basePrice,
    String? imageUrl,
    bool? isBestseller,
    bool? isAvailable,
    List<ProductSizeModel>? sizes,
    List<ToppingModel>? availableToppings,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      isBestseller: isBestseller ?? this.isBestseller,
      isAvailable: isAvailable ?? this.isAvailable,
      sizes: sizes ?? this.sizes,
      availableToppings: availableToppings ?? this.availableToppings,
    );
  }
}
