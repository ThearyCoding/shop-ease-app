import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/constant.dart';
import '../../models/category_model.dart';
import '../locals/shared_pres_service.dart';

final categoryApiProvider = Provider((ref) => CategoryApi());

class CategoryApi {
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final token = await SharedPresService.getToken();

      if (token == null) {
        log('No token available');
        return [];
      }
      final url = Uri.parse('${ConstantApp.baseUrl}/api/categories');
      final response = await http.get(
        url,
        headers: {'authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final categoreis = jsonResponse as List;
        return categoreis
            .map((category) => CategoryModel.fromJson(category))
            .toList();
      } else {
        final jsonResponse = jsonDecode(response.body);
        final error = jsonResponse['error'];
        throw Exception('Failed to load categories. Status Code: $error');
      }
    } catch (e) {
      log("error fetching categories: $e ");
      return [];
    }
  }
}
