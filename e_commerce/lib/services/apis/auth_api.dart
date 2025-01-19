import 'dart:convert';
import 'dart:developer';

import 'package:e_commerce/core/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../locals/shared_pres_service.dart';

final authApi = Provider((ref) => AuthApi());

class AuthApi {
  static const _headers = {
    "x-api-key": "my_super_secret_key",
    "Content-Type": "application/json",
  };

  Future<bool> login(String email, String password) async {
    return _authenticate(email: email, password: password, endpoint: "login");
  }

  Future<bool> register(String name, String email, String password) async {
    return _authenticate(
      email: email,
      password: password,
      endpoint: "register",
      extraBody: {'name': name},
    );
  }

  Future<bool> _authenticate({
    required String email,
    required String password,
    required String endpoint,
    Map<String, dynamic>? extraBody,
  }) async {
    final url = Uri.parse("${ConstantApp.baseUrl}/api/users/$endpoint");
    final body = {
      'email': email,
      'password': password,
      ...?extraBody,
    };

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final token = jsonResponse['token'];

        if (token != null) {
          await SharedPresService.setToken(token);
          log('$endpoint successful');
          return true;
        } else {
          log('Token not found in the response');
          return false;
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        log('$endpoint failed: ${errorResponse['error'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      log('Error during $endpoint: $e');
      return false;
    }
  }
}
