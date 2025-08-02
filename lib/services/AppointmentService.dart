import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/bussiness/appointment_interface.dart';

class AppointmentService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Listar citas del usuario autenticado
  static Future<UserTrainerAppointmentList?> fetchUserAppointments() async {
    try {
      final url = '$_baseUrl/trainer-schedules/user/token';
      print('=== USER APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');

      final response = await NetworkService.get(url);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de citas extraída: $data');
        print('Cantidad de citas: ${data.length}');

        final result = data
            .map((e) => UserTrainerAppointment.fromJson(e))
            .toList();
        print('Resultado final: ${result.length} citas convertidas');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN USER APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Listar citas asignadas al entrenador autenticado
  static Future<TrainerAppointmentList?> fetchTrainerAppointments() async {
    try {
      final url = '$_baseUrl/trainer-schedules/trainer/token';
      print('=== APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');

      final response = await NetworkService.get(url);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de citas extraída: $data');
        print('Cantidad de citas: ${data.length}');

        final result = data.map((e) => TrainerAppointment.fromJson(e)).toList();
        print('Resultado final: ${result.length} citas convertidas');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Listar citas asignadas al nutriólogo autenticado
  static Future<NutritionistAppointmentList?>
  fetchNutritionistAppointments() async {
    try {
      final url = '$_baseUrl/nutritionist-schedules/nutritionist/token';
      print('=== NUTRITIONIST APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');

      final response = await NetworkService.get(url);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de citas extraída: $data');
        print('Cantidad de citas: ${data.length}');

        final result = data
            .map((e) => NutritionistAppointment.fromJson(e))
            .toList();
        print('Resultado final: ${result.length} citas convertidas');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN NUTRITIONIST APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Obtener una cita específica del nutriólogo
  static Future<NutritionistAppointment?> fetchNutritionistAppointmentById(
    int id,
  ) async {
    try {
      final url = '$_baseUrl/nutritionist-schedules/$id';
      print('=== NUTRITIONIST APPOINTMENT BY ID SERVICE DEBUG ===');
      print('URL de consulta: $url');
      print('ID de cita solicitada: $id');

      final response = await NetworkService.get(url);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as Map<String, dynamic>;
        print('Cita extraída: $data');

        final result = NutritionistAppointment.fromJson(data);
        print('Resultado final: Cita ID ${result.id} convertida');
        return result;
      } else if (response.statusCode == 404) {
        print('Cita no encontrada - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN NUTRITIONIST APPOINTMENT BY ID SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Crear cita con entrenador
  static Future<TrainerAppointment?> createTrainerAppointment({
    required int userId,
    required int trainerId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final url = '$_baseUrl/trainer-schedules';
      final body = {
        'user_id': userId,
        'trainer_id': trainerId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      };

      print('=== CREATE TRAINER APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');
      print('Datos a enviar: $body');

      final response = await NetworkService.post(url, body: body);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as Map<String, dynamic>;
        print('Cita creada: $data');

        final result = TrainerAppointment.fromJson(data);
        print('Resultado final: Cita ID ${result.id} creada');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN CREATE TRAINER APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Crear cita con nutriólogo
  static Future<NutritionistAppointment?> createNutritionistAppointment({
    required int userId,
    required int nutritionistId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final url = '$_baseUrl/nutritionist-schedules';
      final body = {
        'user_id': userId,
        'nutritionist_id': nutritionistId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      };

      print('=== CREATE NUTRITIONIST APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');
      print('Datos a enviar: $body');

      final response = await NetworkService.post(url, body: body);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as Map<String, dynamic>;
        print('Cita creada: $data');

        final result = NutritionistAppointment.fromJson(data);
        print('Resultado final: Cita ID ${result.id} creada');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN CREATE NUTRITIONIST APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }
}
