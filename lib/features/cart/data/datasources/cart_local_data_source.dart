import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';

class CartLocalDataSource {
  CartLocalDataSource({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  static const _key = 'cart_items_v1';

  final SharedPreferences _prefs;

  Future<List<CartItemModel>> loadCart() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) return const [];

    return decoded.map((e) {
      return CartItemModel.fromJson(Map<String, dynamic>.from(e as Map));
    }).where((e) => e.quantity > 0).toList(growable: false);
  }

  Future<void> saveCart(List<CartItemModel> items) async {
    final payload = items.map((e) => e.toJson()).toList(growable: false);
    await _prefs.setString(_key, jsonEncode(payload));
  }

  Future<void> clearCart() async {
    await _prefs.remove(_key);
  }
}

