import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/payment/suscription_interface.dart';

class SubscriptionService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Crear suscripción
  static Future<Subscription?> createSubscription({
    required int userId,
    required int membershipId,
    required String startDate,
    required String endDate,
    required String status,
    required bool isRenewable,
    String? canceledAt,
  }) async {
    final fullUrl = '$_baseUrl/subscriptions';
    final body = {
      'user_id': userId,
      'membership_id': membershipId,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'is_renewable': isRenewable,
      'canceled_at': canceledAt,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Subscription(
        id: data['id'],
        userId: data['user_id'],
        membershipId: data['membership_id'],
        startDate: data['start_date'],
        endDate: data['end_date'],
        status: data['status'],
        isRenewable: data['is_renewable'],
        canceledAt: data['canceled_at'],
      );
    }
    return null;
  }

  // Actualizar suscripción
  static Future<Subscription?> updateSubscription({
    required int id,
    required int membershipId,
    required String startDate,
    required String endDate,
    required String status,
    required bool isRenewable,
    String? canceledAt,
  }) async {
    final fullUrl = '$_baseUrl/subscriptions/$id';
    final body = {
      'membership_id': membershipId,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'is_renewable': isRenewable,
      'canceled_at': canceledAt,
    };
    final response = await NetworkService.put(fullUrl, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Subscription(
        id: data['id'],
        userId: data['user_id'],
        membershipId: data['membership_id'],
        startDate: data['start_date'],
        endDate: data['end_date'],
        status: data['status'],
        isRenewable: data['is_renewable'],
        canceledAt: data['canceled_at'],
      );
    }
    return null;
  }

  // Listar suscripciones con filtros
  static Future<SubscriptionList?> fetchSubscriptions({
    int? userId,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    String fullUrl = '$_baseUrl/subscriptions';
    List<String> params = [];
    if (userId != null) params.add('user_id=$userId');
    if (status != null) params.add('status=$status');
    if (startDate != null) params.add('start_date=$startDate');
    if (endDate != null) params.add('end_date=$endDate');
    if (params.isNotEmpty) {
      fullUrl += '?${params.join('&')}';
    }
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Subscription(
        id: e['id'],
        userId: e['user_id'],
        membershipId: e['membership_id'],
        startDate: e['start_date'],
        endDate: e['end_date'],
        status: e['status'],
        isRenewable: e['is_renewable'],
        canceledAt: e['canceled_at'],
      )).toList();
    }
    return null;
  }
}