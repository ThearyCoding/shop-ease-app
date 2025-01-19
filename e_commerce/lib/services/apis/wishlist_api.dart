import 'dart:convert';
import 'dart:developer';
import 'package:e_commerce/models/wishlist_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/constant.dart';
import '../locals/shared_pres_service.dart';

final wishlistApiProvider = Provider((ref) => WishlistApi());

class WishlistApi {
  Future<String?> _getToken() async {
    return await SharedPresService.getToken();
  }

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'authorization': 'Bearer $token'
    };
  }

  Future<void> addWishlist(String productId) async {
    final url = Uri.parse('${ConstantApp.baseUrl}/api/wishlists');

    final token = await _getToken();

    if (token == null) {
      throw Exception('no token available');
    }
    final response = await http.post(url,
        headers: _headers(token), body: jsonEncode({'productId': productId}));
    if (response.statusCode == 201) {
      log("add wishlist successfully");
    } else {
      log('failed to add wishlist');
    }
  }

  Future<Wishlist?> fetchWishlists() async {
    final url = Uri.parse('${ConstantApp.baseUrl}/api/wishlists');
    final token = await _getToken();

    if (token == null) {
      log('No token available');
      return Wishlist.empty();
    }

    try {
      final response = await http.get(
        url,
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final Wishlist wishlist = Wishlist.fromJson(jsonResponse);
        return wishlist;
      } else {
        log('Failed to load wishlist: ${response.statusCode}');
        return Wishlist.empty();
      }
    } catch (error) {
      log('Error fetching wishlist: $error');
      return Wishlist.empty();
    }
  }

  Future<void> removeProductFromWishlist(String productId) async {
    final url = Uri.parse('${ConstantApp.baseUrl}/api/wishlists/$productId');

    final token = await _getToken();

    if (token == null) {
      throw Exception('No token available');
    }

    final response = await http.delete(
      url,
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      log("Product removed from wishlist successfully");
    } else {
      log('Failed to remove product from wishlist');
    }
  }
}
