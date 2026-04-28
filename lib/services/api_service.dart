import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/products';

  Future<Map<String, dynamic>> fetchProducts({int skip = 0, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl?limit=$limit&skip=$skip'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'products': (data['products'] as List)
            .map((e) => Product.fromJson(e))
            .toList(),
        'total': data['total'],
      };
    }
    throw Exception('Failed to load products');
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    }
    throw Exception('Failed to search');
  }
}