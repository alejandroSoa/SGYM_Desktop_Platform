import 'dart:convert';
import '../interfaces/bussiness/food_interface.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';

class FoodService {
  static String get _baseUrl {
    final url = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  // Listar alimentos
  static Future<FoodList?> fetchFoods() async {
    final fullUrl = '$_baseUrl/foods';
    print('[FoodService] GET $fullUrl');
    final response = await NetworkService.get(fullUrl);
    print('[FoodService] Response status: ${response.statusCode}');
    print('[FoodService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Food.fromJson(e)).toList();
    }
    return null;
  }

  // Crear alimento
  static Future<Food?> createFood({
    required String name,
    required double grams,
    required double calories,
    String? otherInfo,
  }) async {
    final fullUrl = '$_baseUrl/foods';
    final body = {
      'name': name,
      'grams': grams,
      'calories': calories,
      'other_info': otherInfo,
    };
    print('[FoodService] POST $fullUrl');
    print('[FoodService] Body: $body');
    final response = await NetworkService.post(fullUrl, body: body);
    print('[FoodService] Response status: ${response.statusCode}');
    print('[FoodService] Response body: ${response.body}');
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Food.fromJson(data);
    }
    return null;
  }

  // Actualizar alimento
  static Future<Food?> updateFood({
    required int id,
    required String name,
    required double grams,
    required double calories,
    String? otherInfo,
  }) async {
    final fullUrl = '$_baseUrl/foods/$id';
    final body = {
      'name': name,
      'grams': grams,
      'calories': calories,
      'other_info': otherInfo,
    };
    print('[FoodService] PUT $fullUrl');
    print('[FoodService] Body: $body');
    final response = await NetworkService.put(fullUrl, body: body);
    print('[FoodService] Response status: ${response.statusCode}');
    print('[FoodService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Food.fromJson(data);
    }
    return null;
  }

  // Obtener alimento por ID
  static Future<Food?> fetchFoodById(int id) async {
    final fullUrl = '$_baseUrl/foods/$id';
    print('[FoodService] GET $fullUrl');
    final response = await NetworkService.get(fullUrl);
    print('[FoodService] Response status: ${response.statusCode}');
    print('[FoodService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Food.fromJson(data);
    }
    return null;
  }

  // Eliminar alimento
  static Future<bool> deleteFood(int id) async {
    final fullUrl = '$_baseUrl/foods/$id';
    print('[FoodService] DELETE $fullUrl');
    final response = await NetworkService.delete(fullUrl);
    print('[FoodService] Response status: ${response.statusCode}');
    print('[FoodService] Response body: ${response.body}');
    return response.statusCode == 200;
  }
}