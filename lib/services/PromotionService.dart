import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/bussiness/promotion_interface.dart';

class PromotionService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Listar promociones
  static Future<PromotionList?> fetchPromotions() async {
    final fullUrl = '$_baseUrl/promotions';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Promotion.fromJson(e)).toList();
    }
    return null;
  }

  // Crear promoción
  static Future<Promotion?> createPromotion({
    required String name,
    required double discount,
    required int membershipId,
  }) async {
    final fullUrl = '$_baseUrl/promotions';
    final body = {
      'name': name,
      'discount': discount,
      'membership_id': membershipId,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Promotion.fromJson(data);
    }
    return null;
  }

  // Obtener promoción por ID
  static Future<Promotion?> fetchPromotionById(int id) async {
    final fullUrl = '$_baseUrl/promotions/$id';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Promotion.fromJson(data);
    }
    return null;
  }

  // Actualizar promoción
  static Future<Promotion?> updatePromotion({
    required int id,
    required String name,
    required double discount,
    required int membershipId,
  }) async {
    final fullUrl = '$_baseUrl/promotions/$id';
    final body = {
      'name': name,
      'discount': discount,
      'membership_id': membershipId,
    };
    final response = await NetworkService.put(fullUrl, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Promotion.fromJson(data);
    }
    return null;
  }

  // Eliminar promoción
  static Future<bool> deletePromotion(int id) async {
    final fullUrl = '$_baseUrl/promotions/$id';
    final response = await NetworkService.delete(fullUrl);
    return response.statusCode == 200;
  }

  // Aplicar promoción a usuario
  static Future<Map<String, dynamic>?> applyPromotionToUser({
    required int promotionId,
    required int userId,
    required String appliedAt,
    required String expiredAt,
  }) async {
    final fullUrl = '$_baseUrl/user-promotions';
    final body = {
      'promotion_id': promotionId,
      'user_id': userId,
      'applied_at': appliedAt,
      'expired_at': expiredAt,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}