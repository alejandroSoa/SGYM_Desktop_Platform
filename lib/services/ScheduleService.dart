import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/bussiness/schedule_interface.dart';

class ScheduleService {
  static String get _baseUrl {
    final url = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  // Crear horario
  static Future<Schedule?> createSchedule({
    required int userId,
    required String startTime,
    required String endTime,
  }) async {
    final fullUrl = '$_baseUrl/schedules';
    final body = {
      'user_id': userId,
      'start_time': startTime,
      'end_time': endTime,
    };
    print('[ScheduleService] POST $fullUrl');
    print('[ScheduleService] Body: $body');
    final response = await NetworkService.post(fullUrl, body: body);
    print('[ScheduleService] Response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Schedule.fromJson(data);
    }
    return null;
  }

  // Listar horarios (opcionalmente por usuario)
  static Future<ScheduleList?> fetchSchedules({int? userId}) async {
    String fullUrl = '$_baseUrl/schedules';
    if (userId != null) {
      fullUrl += '?user_id=$userId';
    }
    print('[ScheduleService] GET $fullUrl');
    final response = await NetworkService.get(fullUrl);
    print('[ScheduleService] Response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Schedule.fromJson(e)).toList();
    }
    return null;
  }

  // Consultar horario por ID
  static Future<Schedule?> fetchScheduleById(int id) async {
    final fullUrl = '$_baseUrl/schedules/$id';
    print('[ScheduleService] GET $fullUrl');
    final response = await NetworkService.get(fullUrl);
    print('[ScheduleService] Response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Schedule.fromJson(data);
    }
    return null;
  }

  // Actualizar horario
  static Future<Schedule?> updateSchedule({
    required int id,
    required int userId,
    required String startTime,
    required String endTime,
  }) async {
    final fullUrl = '$_baseUrl/schedules/$id';
    final body = {
      'user_id': userId,
      'start_time': startTime,
      'end_time': endTime,
    };
    print('[ScheduleService] PUT $fullUrl');
    print('[ScheduleService] Body: $body');
    final response = await NetworkService.put(fullUrl, body: body);
    print('[ScheduleService] Response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Schedule.fromJson(data);
    }
    return null;
  }

  // Eliminar horario
  static Future<bool> deleteSchedule(int id) async {
    final fullUrl = '$_baseUrl/schedules/$id';
    print('[ScheduleService] DELETE $fullUrl');
    final response = await NetworkService.delete(fullUrl);
    print('[ScheduleService] Response: ${response.statusCode} ${response.body}');
    return response.statusCode == 200;
  }
}