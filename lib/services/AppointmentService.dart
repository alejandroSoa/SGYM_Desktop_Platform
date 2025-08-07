import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/bussiness/appointment_interface.dart';

class AppointmentService {

  // Actualizar cita con entrenador
  static Future<TrainerAppointment?> updateTrainerAppointment({
    required int id,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final url = '$_baseUrl/trainer-schedules/$id';
      final body = {
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      };

      print('=== UPDATE TRAINER APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');
      print('Datos a enviar: $body');

      final response = await NetworkService.put(url, body: body);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as Map<String, dynamic>;
        print('Cita actualizada: $data');

        final result = TrainerAppointment.fromJson(data);
        print('Resultado final: Cita ID ${result.id} actualizada');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN UPDATE TRAINER APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Eliminar cita con entrenador
  static Future<bool> deleteTrainerAppointment(int id) async {
    try {
      final url = '$_baseUrl/trainer-schedules/$id';
      print('=== DELETE TRAINER APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');

      final response = await NetworkService.delete(url);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        print('Cita eliminada correctamente.');
        return true;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('=== ERROR EN DELETE TRAINER APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }
  // Listar todas las citas con nutriólogos 
  static Future<NutritionistAppointmentList?> fetchAllNutritionistAppointments({
    int? nutritionistId,
    int? userId,
    String? date,
  }) async {
    try {
      String url = '$_baseUrl/nutritionist-schedules';
      List<String> params = [];
      if (nutritionistId != null) params.add('nutritionist_id=$nutritionistId');
      if (userId != null) params.add('user_id=$userId');
      if (date != null) params.add('date=$date');
      if (params.isNotEmpty) {
        url += '?${params.join('&')}' ;
      }
      print('=== FETCH ALL NUTRITIONIST APPOINTMENTS SERVICE DEBUG ===');
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
      print('=== ERROR EN FETCH ALL NUTRITIONIST APPOINTMENTS SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Actualizar cita con nutriólogo
  static Future<NutritionistAppointment?> updateNutritionistAppointment({
    required int id,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final url = '$_baseUrl/nutritionist-schedules/$id';
      final body = {
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      };

      print('=== UPDATE NUTRITIONIST APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');
      print('Datos a enviar: $body');

      final response = await NetworkService.put(url, body: body);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as Map<String, dynamic>;
        print('Cita actualizada: $data');

        final result = NutritionistAppointment.fromJson(data);
        print('Resultado final: Cita ID ${result.id} actualizada');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN UPDATE NUTRITIONIST APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Eliminar cita con nutriólogo
  static Future<bool> deleteNutritionistAppointment(int id) async {
    try {
      final url = '$_baseUrl/nutritionist-schedules/$id';
      print('=== DELETE NUTRITIONIST APPOINTMENT SERVICE DEBUG ===');
      print('URL de consulta: $url');

      final response = await NetworkService.delete(url);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        print('Cita eliminada correctamente.');
        return true;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('=== ERROR EN DELETE NUTRITIONIST APPOINTMENT SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }
  static String get _baseUrl {
    final url = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  // Listar citas del usuario autenticado
  static Future<UserTrainerAppointmentList?> fetchUserTrainerAppointments() async {
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

    // Listar citas del usuario autenticado
  static Future<UserNutrisionistAppointmentList?> fetchUserNutriosionistAppointments() async {
    try {
      final url = '$_baseUrl/nutrisionist-schedules/user/token';
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
            .map((e) => UserNutrisionistAppointment.fromJson(e))
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
  static Future<TrainerAppointmentList?> fetchTrainerAppointments({required int trainerId}) async {
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
}
