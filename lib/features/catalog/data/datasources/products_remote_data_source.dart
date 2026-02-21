import 'package:flutter_application_1/core/network/api_client.dart';

import '../models/product_model.dart';

class ProductsRemoteDataSource {
  ProductsRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ProductModel>> getProducts() async {
    final uri = Uri.parse('https://fakestoreapi.com/products');
    final jsonList = await _apiClient.getJsonList(uri);
    return jsonList.map((e) {
      if (e is Map<String, dynamic>) return ProductModel.fromJson(e);
      return ProductModel.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList(growable: false);
  }
}
