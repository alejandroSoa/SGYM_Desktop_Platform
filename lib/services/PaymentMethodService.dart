import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/payment/payment_method_interface.dart';
import '../interfaces/user/user_payment_method_interface.dart';

class PaymentMethodService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Listar métodos de pago
  static Future<PaymentMethodList?> fetchPaymentMethods() async {
    final fullUrl = '$_baseUrl/payment-methods';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data
          .map(
            (e) => PaymentMethod(
              id: e['id'],
              code: e['code'],
              name: e['name'],
              description: e['description'],
              isActive: e['is_active'],
            ),
          )
          .toList();
    }
    return null;
  }

  // Crear método de pago
  static Future<PaymentMethod?> createPaymentMethod({
    required String code,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final fullUrl = '$_baseUrl/payment-methods';
    final body = {
      'code': code,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return PaymentMethod(
        id: data['id'],
        code: data['code'],
        name: data['name'],
        description: data['description'],
        isActive: data['is_active'],
      );
    }
    return null;
  }

  // Obtener método de pago por ID
  static Future<PaymentMethod?> fetchPaymentMethodById(int id) async {
    final fullUrl = '$_baseUrl/payment-methods/$id';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return PaymentMethod(
        id: data['id'],
        code: data['code'],
        name: data['name'],
        description: data['description'],
        isActive: data['is_active'],
      );
    }
    return null;
  }

  // Actualizar método de pago
  static Future<PaymentMethod?> updatePaymentMethod({
    required int id,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final fullUrl = '$_baseUrl/payment-methods/$id';
    final body = {
      'name': name,
      'description': description,
      'is_active': isActive,
    };
    final response = await NetworkService.put(fullUrl, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return PaymentMethod(
        id: data['id'],
        code: data['code'],
        name: data['name'],
        description: data['description'],
        isActive: data['is_active'],
      );
    }
    return null;
  }

  // Eliminar método de pago
  static Future<bool> deletePaymentMethod(int id) async {
    final fullUrl = '$_baseUrl/payment-methods/$id';
    final response = await NetworkService.delete(fullUrl);
    return response.statusCode == 200;
  }

  // Crear método de pago del usuario
  static Future<UserPaymentMethod?> createUserPaymentMethod({
    required int userId,
    required String customerId,
    required String paymentMethodId,
    required String brand,
    required String last4,
    required String expMonth,
    required int expYear,
    required bool isDefault,
  }) async {
    final fullUrl = '$_baseUrl/user-payment-methods';
    final body = {
      'user_id': userId,
      'customer_id': customerId,
      'payment_method_id': paymentMethodId,
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
      'is_default': isDefault,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return UserPaymentMethod(
        id: data['id'],
        userId: data['user_id'],
        customerId: data['customer_id'],
        paymentMethodId: data['payment_method_id'],
        brand: data['brand'],
        last4: data['last4'],
        expMonth: int.tryParse(data['exp_month'].toString()) ?? 0,
        expYear: data['exp_year'],
        isDefault: data['is_default'],
        createdAt: data['created_at'],
        updatedAt: data['updated_at'],
      );
    }
    return null;
  }

  // Actualizar método de pago del usuario
  static Future<UserPaymentMethod?> updateUserPaymentMethod({
    required int id,
    required String brand,
    required String expMonth,
    required int expYear,
    required bool isDefault,
  }) async {
    final fullUrl = '$_baseUrl/user-payment-methods/$id';
    final body = {
      'brand': brand,
      'exp_month': expMonth,
      'exp_year': expYear,
      'is_default': isDefault,
    };
    final response = await NetworkService.put(fullUrl, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return UserPaymentMethod(
        id: data['id'],
        userId: data['user_id'],
        customerId: data['customer_id'],
        paymentMethodId: data['payment_method_id'],
        brand: data['brand'],
        last4: data['last4'],
        expMonth: int.tryParse(data['exp_month'].toString()) ?? 0,
        expYear: data['exp_year'],
        isDefault: data['is_default'],
        createdAt: data['created_at'],
        updatedAt: data['updated_at'],
      );
    }
    return null;
  }

  // Listar métodos de pago del usuario
  static Future<UserPaymentMethodList?> fetchUserPaymentMethods(
    int userId,
  ) async {
    final fullUrl = '$_baseUrl/user-payment-methods?user_id=$userId';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data
          .map(
            (e) => UserPaymentMethod(
              id: e['id'],
              userId: e['user_id'],
              customerId: e['customer_id'],
              paymentMethodId: e['payment_method_id'],
              brand: e['brand'],
              last4: e['last4'],
              expMonth: int.tryParse(e['exp_month'].toString()) ?? 0,
              expYear: e['exp_year'],
              isDefault: e['is_default'],
              createdAt: e['created_at'],
              updatedAt: e['updated_at'],
            ),
          )
          .toList();
    }
    return null;
  }

  // Eliminar método de pago del usuario
  static Future<bool> deleteUserPaymentMethod(int id) async {
    final fullUrl = '$_baseUrl/user-payment-methods/$id';
    final response = await NetworkService.delete(fullUrl);
    return response.statusCode == 200;
  }

  // ...existing imports...
  // ...existing class PaymentMethodService...

  // Crear solicitud de pago
  static Future<Map<String, dynamic>?> createPaymentRequest({
    required int userId,
    required int paymentMethodId,
    required String externalReference,
    required double amount,
    required String currency,
    required String description,
    required String metadata,
  }) async {
    final fullUrl = '$_baseUrl/payment-requests';
    final body = {
      'user_id': userId,
      'payment_method_id': paymentMethodId,
      'external_reference': externalReference,
      'amount': amount,
      'currency': currency,
      'description': description,
      'metadata': metadata,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Actualizar estado de la solicitud de pago
  static Future<Map<String, dynamic>?> updatePaymentRequestStatus({
    required int id,
    required String status,
  }) async {
    final fullUrl = '$_baseUrl/payment-requests/$id';
    final body = {'status': status};
    final response = await NetworkService.put(fullUrl, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Listar solicitudes de pago (con filtros opcionales)
  static Future<List<Map<String, dynamic>>?> fetchPaymentRequests({
    int? userId,
    String? status,
  }) async {
    String fullUrl = '$_baseUrl/payment-requests';
    List<String> params = [];
    if (userId != null) params.add('user_id=$userId');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) {
      fullUrl += '?${params.join('&')}';
    }
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  // Registrar pago confirmado
  static Future<Map<String, dynamic>?> createPayment({
    required int paymentRequestId,
    required int subscriptionId,
    required double amount,
    required String paymentDate,
    required String concept,
    required String status,
  }) async {
    final fullUrl = '$_baseUrl/payments';
    final body = {
      'payment_request_id': paymentRequestId,
      'subscription_id': subscriptionId,
      'amount': amount,
      'payment_date': paymentDate,
      'concept': concept,
      'status': status,
    };
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Consultar pagos
  static Future<List<Map<String, dynamic>>?> fetchPayments({
    int? userId,
    String? status,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    String fullUrl = '$_baseUrl/payments';
    List<String> params = [];
    if (userId != null) params.add('user_id=$userId');
    if (status != null) params.add('status=$status');
    if (fechaInicio != null) params.add('fecha_inicio=$fechaInicio');
    if (fechaFin != null) params.add('fecha_fin=$fechaFin');
    if (params.isNotEmpty) {
      fullUrl += '?${params.join('&')}';
    }
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }
}
