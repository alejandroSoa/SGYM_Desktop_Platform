import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../network/NetworkService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static String get _baseUrl {
    final url = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  // Inicializar el servicio
  static Future<void> initialize() async {
    print('[NOTIFICATION_SERVICE] Inicializando...');

    // Solicitar permisos
    await _requestPermissions();

    // Configurar notificaciones locales
    await _initializeLocalNotifications();

    // Configurar listeners
    _configureListeners();

    // Obtener y guardar FCM token
    await _saveFCMToken();
  }

  // Solicitar permisos
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('[NOTIFICATION_SERVICE] Permisos: ${settings.authorizationStatus}');
  }

  // Configurar notificaciones locales
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Configurar listeners de Firebase Messaging
  static void _configureListeners() {
    // Cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[NOTIFICATION_SERVICE] Mensaje en foreground: ${message.data}');

      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Cuando el usuario toca una notificación (app cerrada o en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[NOTIFICATION_SERVICE] Notificación tocada: ${message.data}');
      _handleNotificationTap(message);
    });
  }

  // Obtener y guardar FCM token
  static Future<void> _saveFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('=== FCM TOKEN OBTENIDO ===');
        print('FCM Token: $token');
        print('==========================');

        // Por ahora solo imprimir, no enviar al servidor
        // await _sendTokenToServer(token); // ← Comentado temporalmente
      }

      // Listener para cuando el token se actualice
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        print('=== FCM TOKEN ACTUALIZADO ===');
        print('Nuevo FCM Token: $token');
        print('=============================');

        // Por ahora solo imprimir, no enviar al servidor
        // _sendTokenToServer(token); // ← Comentado temporalmente
      });
    } catch (e) {
      print('[NOTIFICATION_SERVICE] Error obteniendo FCM token: $e');
    }
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

  // Mostrar notificación local
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'sgym_channel',
          'SGYM Notifications',
          channelDescription: 'Notificaciones de SGYM',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  // Manejar tap en notificación
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      Map<String, dynamic> data = jsonDecode(notificationResponse.payload!);
      _handleNotificationTap(RemoteMessage(data: data));
    }
  }

  // Manejar el tap en notificaciones
  static void _handleNotificationTap(RemoteMessage message) {
    print('[NOTIFICATION_SERVICE] Manejando tap con data: ${message.data}');

    String? type = message.data['type'];
    String? targetId = message.data['target_id'];

    switch (type) {
      case 'routine_assigned':
        print('[NOTIFICATION_SERVICE] Navegando a rutinas - ID: $targetId');
        // Aquí puedes agregar navegación específica si es necesario
        break;
      case 'diet_assigned':
        print('[NOTIFICATION_SERVICE] Navegando a dietas - ID: $targetId');
        break;
      case 'appointment_created':
        print('[NOTIFICATION_SERVICE] Navegando a citas - ID: $targetId');
        break;
      default:
        print('[NOTIFICATION_SERVICE] Tipo de notificación desconocido: $type');
        break;
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
