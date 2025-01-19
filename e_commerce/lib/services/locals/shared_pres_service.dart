
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsService = Provider((ref) => SharedPresService());

class SharedPresService {
  static Future<void> setToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", token);
      log(token);
    } catch (e) {
      log("Error setting token : $e");
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      return token;
    } catch (e) {
      log("Error setting token : $e");
      return "";
    }
  }

  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
    } catch (e) {
      log("Error clearing token : $e");
    }
  }
}
