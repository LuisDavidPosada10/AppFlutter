import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required http.Client client}) : _client = client;

  final http.Client _client;

  Future<List<dynamic>> getJsonList(Uri uri) async {
    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: 'Request failed: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const ApiException(message: 'Unexpected response format');
    }
    return decoded;
  }
}

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

