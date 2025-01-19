import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/constant.dart';
import '../../models/product_model.dart';
import '../locals/shared_pres_service.dart';

final productApiProvider = Provider((ref) => ProductApi());

class ProductApi {
  Future<String?> _getToken() async {
    return await SharedPresService.getToken();
  }
  Future<List<Product>> fetchProductsByCategory(String categoryId) async{
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token available');
      }
      final url = Uri.parse("${ConstantApp.baseUrl}/api/products/category/$categoryId");
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body) as List;
        return responseJson
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        final jsonResponse = jsonDecode(response.body);
        final error = jsonResponse['error'];
        throw Exception("Product fetch failed: $error");
      }
    } catch (e) {
      log("Error fetching products: $e");
      return [];
    }
  }
  Future<List<Product>> fetchProducts() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token available');
      }
      final url = Uri.parse("${ConstantApp.baseUrl}/api/products");
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body) as List;
        return responseJson
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        final jsonResponse = jsonDecode(response.body);
        final error = jsonResponse['error'];
        throw Exception("Product fetch failed: $error");
      }
    } catch (e) {
      log("Error fetching products: $e");
      return [];
    }
  }
}
