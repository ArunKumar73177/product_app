import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> products = [];
  List<String> categories = [];
  List<int> wishlist = [];
  List<Product> _wishlistedProducts = [];

  String selectedCategory = 'All';
  RangeValues priceRange = const RangeValues(0, 5000);
  bool isLoading = false;
  bool hasMore = true;
  int skip = 0;
  final int limit = 10;
  String searchQuery = '';

  List<Product> get wishlistedProducts => _wishlistedProducts;

  List<Product> get filteredProducts {
    return products.where((p) {
      final inPrice =
          p.price >= priceRange.start && p.price <= priceRange.end;
      return inPrice;
    }).toList();
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      products = [];
      skip = 0;
      hasMore = true;
    }
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();

    try {
      final result = await _api.fetchProducts(
        skip: skip,
        limit: limit,
        category: selectedCategory,
      );
      final newProducts = result['products'] as List<Product>;
      products.addAll(newProducts);
      skip += limit;
      hasMore = products.length < (result['total'] as int);
    } catch (e) {
      debugPrint('Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    searchQuery = query;
    if (query.isEmpty) {
      await loadProducts(reset: true);
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      products = await _api.searchProducts(query);
      hasMore = false;
    } catch (e) {
      debugPrint('Error: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    categories = await _api.fetchCategories();
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    loadProducts(reset: true);
  }

  void setPriceRange(RangeValues values) {
    priceRange = values;
    notifyListeners();
  }

  void toggleWishlist(Product product) async {
    if (wishlist.contains(product.id)) {
      wishlist.remove(product.id);
      _wishlistedProducts.removeWhere((p) => p.id == product.id);
    } else {
      wishlist.add(product.id);
      _wishlistedProducts.add(product);
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'wishlist', wishlist.map((e) => e.toString()).toList());
    notifyListeners();
  }

  bool isWishlisted(int productId) => wishlist.contains(productId);

  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('wishlist') ?? [];
    wishlist = saved.map(int.parse).toList();

    // Fetch each wishlisted product from API so wishlist
    // works even if the product isn't in the current loaded batch.
    _wishlistedProducts = [];
    for (final id in wishlist) {
      try {
        final response = await http.get(
          Uri.parse('https://dummyjson.com/products/$id'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _wishlistedProducts.add(Product.fromJson(data));
        }
      } catch (e) {
        debugPrint('Failed to load wishlisted product $id: $e');
      }
    }
    notifyListeners();
  }
}