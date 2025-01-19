import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constant.dart';
import '../../models/cart.dart';
import '../../models/cart_item.dart';
import 'package:http/http.dart' as http;

import '../locals/shared_pres_service.dart';
final cartApiProvider = Provider<CartApi>((ref) {
  return CartApi();
});
class CartApi {
  Future<String?> _getToken() async {
    return await SharedPresService.getToken();
  }

  Future<void> addToCart(CartItem item) async {
    final token = await _getToken();
    final url = Uri.parse("${ConstantApp.baseUrl}/api/carts");

    final requestBody = {
      'items': [
        {'product': item.product.id, 'quantity': item.quantity}
      ]
    };

    if (token == null) {
      log('No token available');
      return;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      log('Item added to cart');
    } else {
      final jsonResponse = jsonDecode(response.body);
      final error = jsonResponse['message'] ?? jsonResponse['error'];
      log('Failed to add item to cart: $error');
    }
  }

  Future<Cart> fetchCart() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token available');
    }

    final response = await http.get(
      Uri.parse('${ConstantApp.baseUrl}/api/carts'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return Cart.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> updateQuantity(
      int quantity, String cartId, String itemId) async {
    final token = await _getToken();
    if (token == null) {
      log('No token available');
      return;
    }

    final url =
        Uri.parse("${ConstantApp.baseUrl}/api/carts/$cartId/items/$itemId");
    await http.patch(
      url,
      headers: {
        'authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'quantity': quantity}),
    );
  }

  Future<void> deleteCartItems(String cartId, String itemId) async {
    final token = await _getToken();
    if (token == null) {
      log('No token available');
      return;
    }

    final url =
        Uri.parse("${ConstantApp.baseUrl}/api/carts/$cartId/Items/$itemId");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(jsonResponse['message'] ?? 'Cart item removed successfully');
      } else {
        final jsonResponse = jsonDecode(response.body);
        log('Failed to delete cart item: ${jsonResponse['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      log('Error during cart item deletion: $e');
    }
  }
}
