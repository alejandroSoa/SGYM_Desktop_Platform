
import 'package:flutter/material.dart';
import 'dart:convert';
import '../network/NetworkService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {

  static String get _baseUrl {
    final url = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  // Inicializar el servicio
  static Future<void> initialize() async {
    print('[NOTIFICATION_SERVICE] Inicializando...');
  }

  


  // Enviar token al servidor
  static Future<void> _sendTokenToServer(String token) async {
    try {
      final url = '$_baseUrl/users/fcm-token';
      final body = {'fcm_token': token};

      final response = await NetworkService.post(url, body: body);

      if (response.statusCode == 200) {
        print('[NOTIFICATION_SERVICE] FCM Token guardado exitosamente');
      } else {
        print(
          '[NOTIFICATION_SERVICE] Error guardando FCM token: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[NOTIFICATION_SERVICE] Error enviando FCM token al servidor: $e');
    }
  }


  // Método genérico para solicitar al backend que envíe una notificación
  static Future<void> sendNotificationToBackend({
    required int userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final url = '$_baseUrl/notifications/send';
      final requestBody = {
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'data': data ?? {},
      };

      print('=== ENVIANDO NOTIFICACIÓN AL BACKEND ===');
      print('URL: $url');
      print('Usuario ID: $userId');
      print('Tipo: $type');
      print('Título: $title');
      print('Mensaje: $body');
      print('Data adicional: $data');
      print('=======================================');

      final response = await NetworkService.post(url, body: requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
          '[NOTIFICATION_SERVICE] Notificación enviada exitosamente al backend',
        );
        print('[NOTIFICATION_SERVICE] Respuesta: ${response.body}');
      } else {
        print(
          '[NOTIFICATION_SERVICE] Error enviando notificación: ${response.statusCode}',
        );
        print('[NOTIFICATION_SERVICE] Respuesta: ${response.body}');
      }
    } catch (e) {
      print('[NOTIFICATION_SERVICE] Error en sendNotificationToBackend: $e');
    }
  }

  // Método específico para rutina asignada
  static Future<void> sendRoutineAssignedNotification({
    required int userId,
  }) async {
    await sendNotificationToBackend(
      userId: userId,
      type: 'routine_assigned',
      title: '💪 Nueva Rutina Asignada',
      body: 'Tu entrenador ha asignado una nueva rutina.',
      data: {'type': 'routine_assigned', 'target_screen': 'routines'},
    );
  }

  // Método específico para dieta asignada
  static Future<void> sendDietAssignedNotification({
    required int userId,
  }) async {
    await sendNotificationToBackend(
      userId: userId,
      type: 'diet_assigned',
      title: '🥗 Nueva Dieta Asignada',
      body: 'Tu nutriólogo ha asignado una nueva dieta.',
      data: {'type': 'diet_assigned', 'target_screen': 'diets'},
    );
  }

  // Obtener lista de notificaciones del backend
  static Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final url = '$_baseUrl/notifications';
      final response = await NetworkService.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('[NOTIFICATION_SERVICE] Error al obtener notificaciones: $e');
    }
    return [];
  }

  // Eliminar notificación por ID
  static Future<bool> deleteNotification(int id) async {
    try {
      final url = '$_baseUrl/notifications/$id';
      final response = await NetworkService.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print('[NOTIFICATION_SERVICE] Error al eliminar notificación: $e');
      return false;
    }
  }
}
