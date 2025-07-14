import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/payment/membership_interface.dart';

class MembershipService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Listar membresías
  static Future<MembershipList?> fetchMemberships() async {
    final fullUrl = '$_baseUrl/memberships';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Membership(
        id: e['id'],
        name: e['name'],
        durationDays: e['duration_days'],
        price: (e['price'] as num).toDouble(),
      )).toList();
    }
    return null;
  }

  // Crear membresía
  static Future<Membership?> createMembership({
    required String name,
    required int durationDays,
    required double price,
  }) async {
    final fullUrl = '$_baseUrl/memberships';
    final body = {
      'name': name,
      'duration_days': durationDays,
      'price': price,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Membership(
        id: data['id'],
        name: data['name'],
        durationDays: data['duration_days'],
        price: (data['price'] as num).toDouble(),
      );
    }
    return null;
  }

  // Obtener membresía por ID
  static Future<Membership?> fetchMembershipById(int id) async {
    final fullUrl = '$_baseUrl/memberships/$id';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Membership(
        id: data['id'],
        name: data['name'],
        durationDays: data['duration_days'],
        price: (data['price'] as num).toDouble(),
      );
    }
    return null;
  }

  // Actualizar membresía
  static Future<Membership?> updateMembership({
    required int id,
    required String name,
    required int durationDays,
    required double price,
  }) async {
    final fullUrl = '$_baseUrl/memberships/$id';
    final body = {
      'name': name,
      'duration_days': durationDays,
      'price': price,
    };
    final response = await NetworkService.put(fullUrl, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Membership(
        id: data['id'],
        name: data['name'],
        durationDays: data['duration_days'],
        price: (data['price'] as num).toDouble(),
      );
    }
    return null;
  }

  // Eliminar membresía
  static Future<bool> deleteMembership(int id) async {
    final fullUrl = '$_baseUrl/memberships/$id';
    final response = await NetworkService.delete(fullUrl);
    return response.statusCode == 200;
  }
}