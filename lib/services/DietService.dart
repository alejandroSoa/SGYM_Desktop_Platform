import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/bussiness/diet_food_interface.dart';

class DietService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Listar dietas
  static Future<List<Map<String, dynamic>>?> fetchDiets() async {
    final fullUrl = '$_baseUrl/diets';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  // Crear dieta
  static Future<Map<String, dynamic>?> createDiet({
    required String day,
    required String name,
    String? description,
    required int userId,
  }) async {
    final fullUrl = '$_baseUrl/diets';
    final body = {
      'day': day,
      'name': name,
      'description': description,
      'user_id': userId,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Actualizar dieta
  static Future<Map<String, dynamic>?> updateDiet({
    required int id,
    required String day,
    required String name,
    String? description,
    required int userId,
  }) async {
    final fullUrl = '$_baseUrl/diets/$id';
    final body = {
      'day': day,
      'name': name,
      'description': description,
      'user_id': userId,
    };
    final response = await NetworkService.put(fullUrl, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Obtener dieta por ID
  static Future<Map<String, dynamic>?> fetchDietById(int id) async {
    final fullUrl = '$_baseUrl/diets/$id';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Eliminar dieta
  static Future<bool> deleteDiet(int id) async {
    final fullUrl = '$_baseUrl/diets/$id';
    final response = await NetworkService.delete(fullUrl);
    return response.statusCode == 200;
  }

  // Agregar alimentos a dieta
  static Future<DietFoodList?> addFoodsToDiet({
    required int dietId,
    required List<int> foodIds,
  }) async {
    final fullUrl = '$_baseUrl/diets/$dietId/foods';
    final body = {
      'food_ids': foodIds,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => DietFood.fromJson(e)).toList();
    }
    return null;
  }

  // Listar alimentos de una dieta
  static Future<List<Map<String, dynamic>>?> fetchFoodsOfDiet(int dietId) async {
    final fullUrl = '$_baseUrl/diets/$dietId/foods';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  // Eliminar alimento de una dieta
  static Future<bool> removeFoodFromDiet({
    required int dietId,
    required int dietFoodId,
  }) async {
    final fullUrl = '$_baseUrl/diets/$dietId/foods/$dietFoodId';
    final response = await NetworkService.delete(fullUrl);
    return response.statusCode == 200;
  } 
}