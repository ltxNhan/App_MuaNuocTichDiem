class CategoryModel {
  final int id;
  final String name;
  final String? iconName;
  final int displayOrder;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    required this.displayOrder,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      name: json['name']?.toString() ?? '',
      iconName: json['icon_name']?.toString(),
      displayOrder: (json['display_order'] is num) ? (json['display_order'] as num).toInt() : 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? iconName,
    int? displayOrder,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
