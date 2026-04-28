import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> products = [];
  List<int> wishlist = [];
  bool isLoading = false;
  bool hasMore = true;
  int skip = 0;
  final int limit = 10;

  Future<void> loadProducts() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();

    final result = await _api.fetchProducts(skip: skip, limit: limit);
    final newProducts = result['products'] as List<Product>;
    products.addAll(newProducts);
    skip += limit;
    hasMore = products.length < result['total'];
    isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      products = [];
      skip = 0;
      hasMore = true;
      await loadProducts();
      return;
    }
    products = await _api.searchProducts(query);
    notifyListeners();
  }

  void toggleWishlist(int productId) async {
    if (wishlist.contains(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
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
    notifyListeners();
  }
}