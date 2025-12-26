import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:laza/models/product.dart';  // Import the main Product model

class ProductService {
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        Fluttertoast.showToast(msg: 'Failed to load products');
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Network error: $e');
      return [];
    }
  }

  Future<Product?> fetchProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load product details');
    }
    return null;
  }
}