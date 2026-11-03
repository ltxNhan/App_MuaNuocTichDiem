import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/topping_model.dart';

class MenuRepository {
  final DioClient _dioClient;

  MenuRepository(this._dioClient);

  bool get _isSupabaseConfigured {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // 1. QUẢN LÝ DANH MỤC (CATEGORIES) SUPABASE
  // ==========================================

  Future<List<CategoryModel>> getCategories() async {
    // 1. Ưu tiên lấy từ Supabase (bảng categories)
    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        final res = await supabase
            .from('categories')
            .select()
            .order('display_order', ascending: true);

        if (res.isNotEmpty) {
          final list = res.map((json) => CategoryModel.fromJson(json)).toList();
          if (!list.any((c) => c.id == 1 || c.name.toLowerCase() == 'tất cả')) {
            list.insert(
              0,
              const CategoryModel(
                id: 1,
                name: 'Tất cả',
                iconName: 'all_inclusive',
                displayOrder: 0,
                isActive: true,
              ),
            );
          }
          _fallbackCategories = List<CategoryModel>.from(list);
          return List<CategoryModel>.from(list);
        }
      } catch (e) {
        debugPrint('Supabase getCategories error: $e');
      }
    }

    // 2. Thử qua REST API / Dio
    try {
      final response = await _dioClient.dio.get(AppEndpoints.categories);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list.map((json) => CategoryModel.fromJson(json)).toList();
      }
    } catch (_) {}

    // 3. Fallback: Luôn tạo bản sao List mới
    return List<CategoryModel>.from(_fallbackCategories);
  }

  Future<CategoryModel> addCategory(CategoryModel category) async {
    CategoryModel finalCategory = category;

    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        final insertData = <String, dynamic>{
          'name': category.name,
          'icon_name': category.iconName,
          'display_order': category.displayOrder,
          'is_active': category.isActive,
        };

        final res = await supabase
            .from('categories')
            .insert(insertData)
            .select()
            .single();

        finalCategory = CategoryModel.fromJson(res);
      } catch (e) {
        debugPrint('Supabase addCategory error: $e');
      }
    }

    final idx = _fallbackCategories.indexWhere(
      (c) => c.id == finalCategory.id || c.name.toLowerCase() == finalCategory.name.toLowerCase(),
    );
    if (idx != -1) {
      _fallbackCategories[idx] = finalCategory;
    } else {
      _fallbackCategories.add(finalCategory);
    }

    return finalCategory;
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('categories')
            .update({
              'name': category.name,
              'icon_name': category.iconName,
              'display_order': category.displayOrder,
              'is_active': category.isActive,
            })
            .eq('id', category.id);
      } catch (e) {
        debugPrint('Supabase updateCategory error: $e');
      }
    }

    final idx = _fallbackCategories.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _fallbackCategories[idx] = category;
    }
  }

  Future<void> deleteCategory(int id) async {
    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('categories').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteCategory error: $e');
      }
    }

    _fallbackCategories.removeWhere((c) => c.id == id);
  }

  Future<void> toggleCategoryActive(int id, bool isActive) async {
    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('categories')
            .update({'is_active': isActive})
            .eq('id', id);
      } catch (e) {
        debugPrint('Supabase toggleCategoryActive error: $e');
      }
    }

    final idx = _fallbackCategories.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final current = _fallbackCategories[idx];
      _fallbackCategories[idx] = current.copyWith(isActive: isActive);
    }
  }

  // ==========================================
  // 2. QUẢN LÝ MÓN ĂN (PRODUCTS) SUPABASE
  // ==========================================

  Future<List<ProductModel>> getProducts({int? categoryId, String? search, bool? bestsellerOnly}) async {
    // 1. Ưu tiên lấy từ Supabase bảng products
    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        var query = supabase.from('products').select();

        if (categoryId != null && categoryId != 1) {
          query = query.eq('category_id', categoryId);
        }
        if (bestsellerOnly == true) {
          query = query.eq('is_bestseller', true);
        }

        final res = await query.order('id', ascending: false);
        if (res.isNotEmpty) {
          var list = res.map((json) => ProductModel.fromJson(json)).toList();
          if (search != null && search.isNotEmpty) {
            final q = search.toLowerCase();
            list = list
                .where((p) => p.name.toLowerCase().contains(q) || (p.description?.toLowerCase().contains(q) ?? false))
                .toList();
          }
          if (categoryId == null || categoryId == 1) {
            _fallbackProducts = List<ProductModel>.from(list);
          }
          return List<ProductModel>.from(list);
        }
      } catch (e) {
        debugPrint('Supabase getProducts error: $e');
      }
    }

    // 2. Thử qua REST API / Dio
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null && categoryId != 1) queryParams['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (bestsellerOnly == true) queryParams['bestseller'] = true;

      final response = await _dioClient.dio.get(
        AppEndpoints.products,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list.map((json) => ProductModel.fromJson(json)).toList();
      }
    } catch (_) {}

    // 3. Fallback: Luôn clone list mới để không chia sẻ tham chiếu
    var list = List<ProductModel>.from(_fallbackProducts);
    if (categoryId != null && categoryId != 1) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    if (bestsellerOnly == true) {
      list = list.where((p) => p.isBestseller).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where((p) => p.name.toLowerCase().contains(q) || (p.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return List<ProductModel>.from(list);
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    ProductModel finalProduct = product;

    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        final insertData = <String, dynamic>{
          'category_id': product.categoryId,
          'name': product.name,
          'description': product.description,
          'base_price': product.basePrice,
          'image_url': product.imageUrl,
          'is_bestseller': product.isBestseller,
          'is_available': product.isAvailable,
        };

        final res = await supabase
            .from('products')
            .insert(insertData)
            .select()
            .single();

        finalProduct = ProductModel.fromJson(res);
      } catch (e) {
        debugPrint('Supabase addProduct error: $e');
      }
    }

    final idx = _fallbackProducts.indexWhere((p) => p.id == finalProduct.id);
    if (idx != -1) {
      _fallbackProducts[idx] = finalProduct;
    } else {
      _fallbackProducts.insert(0, finalProduct);
    }

    return finalProduct;
  }

  Future<void> updateProduct(ProductModel product) async {
    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('products')
            .update({
              'category_id': product.categoryId,
              'name': product.name,
              'description': product.description,
              'base_price': product.basePrice,
              'image_url': product.imageUrl,
              'is_bestseller': product.isBestseller,
              'is_available': product.isAvailable,
            })
            .eq('id', product.id);
      } catch (e) {
        debugPrint('Supabase updateProduct error: $e');
      }
    }

    final idx = _fallbackProducts.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _fallbackProducts[idx] = product;
    }
  }

  Future<void> deleteProduct(int id) async {
    // Xóa trực tiếp khỏi Supabase
    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('products').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteProduct error: $e');
      }
    }

    _fallbackProducts.removeWhere((p) => p.id == id);
  }

  Future<void> toggleAvailability(int id, bool newStatus) async {
    if (_isSupabaseConfigured) {
      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('products')
            .update({'is_available': newStatus})
            .eq('id', id);
      } catch (e) {
        debugPrint('Supabase toggleAvailability error: $e');
      }
    }

    final idx = _fallbackProducts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _fallbackProducts[idx] = _fallbackProducts[idx].copyWith(isAvailable: newStatus);
    }
  }

  void updatePrice(int id, double price) {
    if (_isSupabaseConfigured) {
      try {
        Supabase.instance.client
            .from('products')
            .update({'base_price': price})
            .eq('id', id);
      } catch (_) {}
    }
    final idx = _fallbackProducts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _fallbackProducts[idx] = _fallbackProducts[idx].copyWith(basePrice: price);
    }
  }

  Future<List<ToppingModel>> getToppings() async {
    try {
      final response = await _dioClient.dio.get(AppEndpoints.toppings);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list.map((json) => ToppingModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return List<ToppingModel>.from(_fallbackToppings);
  }

  // Production Fallback Data
  static List<CategoryModel> _fallbackCategories = [
    const CategoryModel(id: 1, name: 'Tất cả', iconName: 'all_inclusive', displayOrder: 1, isActive: true),
    const CategoryModel(id: 2, name: 'Trà sữa', iconName: 'local_cafe', displayOrder: 2, isActive: true),
    const CategoryModel(id: 3, name: 'Cà phê', iconName: 'coffee', displayOrder: 3, isActive: true),
    const CategoryModel(id: 4, name: 'Trà trái cây', iconName: 'eco', displayOrder: 4, isActive: true),
    const CategoryModel(id: 5, name: 'Đá xay', iconName: 'ac_unit', displayOrder: 5, isActive: true),
  ];

  static const List<ToppingModel> _fallbackToppings = [
    ToppingModel(id: 1, name: 'Trân châu đen dẻo', price: 10000, isAvailable: true),
    ToppingModel(id: 2, name: 'Trân châu trắng giòn 3Q', price: 10000, isAvailable: true),
    ToppingModel(id: 3, name: 'Kem Cheese Macchiato béo mặn', price: 15000, isAvailable: true),
    ToppingModel(id: 4, name: 'Thạch dừa non tươi', price: 8000, isAvailable: true),
    ToppingModel(id: 5, name: 'Pudding trứng phô mai', price: 12000, isAvailable: true),
    ToppingModel(id: 6, name: 'Hạt sen Huế hầm đường phèn', price: 15000, isAvailable: true),
  ];

  static List<ProductModel> _fallbackProducts = [
    ProductModel(
      id: 1,
      categoryId: 2,
      name: 'Trà Sữa Hoàng Gia',
      description: 'Vị trà Ceylon thượng hạng kết hợp cùng sữa tươi béo ngậy và trân châu đường đen dẻo dai',
      basePrice: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1558857563-b37cf5a7c2a7?auto=format&fit=crop&w=600&q=80',
      isBestseller: true,
      isAvailable: true,
      sizes: const [
        ProductSizeModel(id: 1, productId: 1, sizeName: 'S', extraPrice: 0),
        ProductSizeModel(id: 2, productId: 1, sizeName: 'M', extraPrice: 6000),
        ProductSizeModel(id: 3, productId: 1, sizeName: 'L', extraPrice: 12000),
      ],
      availableToppings: _fallbackToppings,
    ),
    ProductModel(
      id: 2,
      categoryId: 2,
      name: 'Cloudy Matcha Latte',
      description: 'Matcha Uji Nhật Bản nguyên chất với lớp foam sữa mây bồng bềnh mịn màng',
      basePrice: 52000,
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80',
      isBestseller: true,
      isAvailable: true,
      sizes: const [
        ProductSizeModel(id: 4, productId: 2, sizeName: 'M', extraPrice: 0),
        ProductSizeModel(id: 5, productId: 2, sizeName: 'L', extraPrice: 8000),
      ],
      availableToppings: _fallbackToppings,
    ),
  ];
}
