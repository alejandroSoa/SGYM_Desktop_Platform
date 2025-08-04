import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/bussiness/diet_food_interface.dart';
import '../interfaces/bussiness/diet_interface.dart';

class DietService {
  // Asignar dieta a usuario para un día específico
  static Future<Map<String, dynamic>?> assignDietToUser({
    required int dietId,
    required int userId,
    required String day,
  }) async {
    final fullUrl = '$_baseUrl/user_diet';
    final body = {
      'diet_id': dietId,
      'user_id': userId,
      'day': day,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
  
  static String get _baseUrl {
    final url = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  // Listar dietas
  static Future<DietList?> fetchDiets() async {
    try {
      final fullUrl = '$_baseUrl/diets';
      print('=== DIET SERVICE DEBUG ===');
      print('URL de consulta: $fullUrl');

      final response = await NetworkService.get(fullUrl);

      print('Status code de respuesta: \\${response.statusCode}');
      print('Headers de respuesta: \\${response.headers}');
      print('Cuerpo de respuesta: \\${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: \\${responseData}');

        final data = responseData['data'] as List;
        print('Lista de dietas extraída: \\${data}');
        print('Cantidad de dietas: \\${data.length}');

        final result = data.map((e) => Diet.fromJson(e)).toList();
        print('Resultado final: \\${result}');
        return result;
      } else {
        print('Error en respuesta - Status: \\${response.statusCode}');
        print('Mensaje de error: \\${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN DIET SERVICE ===');
      print('Excepción capturada: \\${e}');
      print('Tipo de excepción: \\${e.runtimeType}');
      rethrow;
    }
  }

  // Crear dieta
  static Future<Map<String, dynamic>?> createDiet({
    required String name,
    String? description,
  }) async {
    final fullUrl = '$_baseUrl/diets';
    final body = {
      'name': name,
      'description': description,
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
    required String name,
    String? description,
  }) async {
    final fullUrl = '$_baseUrl/diets/$id';
    final body = {
      'name': name,
      'description': description,
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
    final body = {'food_ids': foodIds};
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => DietFood.fromJson(e)).toList();
    }
    return null;
  }

  // Listar alimentos de una dieta
  static Future<List<Map<String, dynamic>>?> fetchFoodsOfDiet(
    int dietId,
  ) async {
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
