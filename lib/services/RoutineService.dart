import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../interfaces/bussiness/routine_excersice_interface.dart';
import '../network/NetworkService.dart';
import 'UserService.dart';

class RoutineService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Listar rutinas
  static Future<RoutineList?> fetchRoutines() async {
    try {
      final url = '$_baseUrl/routines';
      final response = await NetworkService.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        return data.map((e) => Routine.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      print('Error in fetchRoutines: $e');
      rethrow;
    }
  }

  // Obtener las últimas 5 rutinas del usuario actual
  static Future<RoutineList?> fetchUserRecentRoutines() async {
    try {
      // Obtener el usuario actual
      final user = await UserService.getUser();
      if (user == null || user['id'] == null) {
        print('No se pudo obtener el usuario actual');
        return [];
      }

      final userId = user['id'];
      print('Usuario actual ID: $userId (tipo: ${userId.runtimeType})');
      
      final url = '$_baseUrl/routines';
      print('URL de consulta: $url');
      final response = await NetworkService.get(url);
      
      print('Status code de respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Respuesta completa de la API: $responseData');
        
        final data = responseData['data'] as List;
        print('Total de rutinas en la API: ${data.length}');
        
        // Mostrar cada rutina completa
        for (int i = 0; i < data.length; i++) {
          print('Rutina $i: ${data[i]}');
        }

        // Filtrar rutinas por userId y obtener las últimas 5
        final userRoutines = data
            .where((routine) {
              final routineUserId = routine['userId'];
              print('Comparando: rutina userId=$routineUserId (tipo: ${routineUserId.runtimeType}) con usuario=$userId (tipo: ${userId.runtimeType})');
              return routine['userId'] == userId;
            })
            .map((e) => Routine.fromJson(e))
            .toList();

        // Mostrar resultados del filtrado
        print('FILTRADO: Se encontraron ${userRoutines.length} rutinas para el usuario $userId');
        for (int i = 0; i < userRoutines.length; i++) {
          print('Rutina filtrada $i: ${userRoutines[i].name} (ID: ${userRoutines[i].id})');
        }

        // Ordenar por ID (más recientes primero) y tomar las últimas 5
        userRoutines.sort((a, b) => b.id.compareTo(a.id));
        final recentRoutines = userRoutines.take(5).toList();

        print('FINAL: Devolviendo ${recentRoutines.length} rutinas recientes para el usuario $userId');
        return recentRoutines;
      }
      return [];
    } catch (e) {
      print('Error in fetchUserRecentRoutines: $e');
      return [];
    }
  }

  // Crear rutina
  static Future<Routine?> createRoutine({
    required String day,
    required String name,
    String? description,
    required int userId,
  }) async {
    try {
      final url = '$_baseUrl/routines';
      final body = {
        'day': day,
        'name': name,
        'description': description,
        'user_id': userId,
      };

      print('Creating routine with URL: $url');
      print('Body: $body');

      final response = await NetworkService.post(url, body: body);

      print('Create routine response status: ${response.statusCode}');
      print('Create routine response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['data'];
        print('Created routine data: $data');
        return Routine.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error in createRoutine: $e');
      rethrow;
    }
  }

  // Actualizar rutina
  static Future<Routine?> updateRoutine({
    required int id,
    required String day,
    required String name,
    String? description,
  }) async {
    final url = '$_baseUrl/routines/$id';
    final body = {'day': day, 'name': name, 'description': description};
    final response = await NetworkService.put(url, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Routine.fromJson(data);
    }
    return null;
  }

  // Eliminar rutina
  static Future<bool> deleteRoutine(int id) async {
    final url = '$_baseUrl/routines/$id';
    final response = await NetworkService.delete(url);

    return response.statusCode == 200;
  }

  // Obtener rutina por ID
  static Future<Routine?> fetchRoutineById(int id) async {
    final url = '$_baseUrl/routines/$id';
    final response = await NetworkService.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Routine.fromJson(data);
    }
    return null;
  }

  // Asignar ejercicio a rutina
  static Future<RoutineExercise?> assignExerciseToRoutine({
    required int routineId,
    required int exerciseId,
  }) async {
    final url = '$_baseUrl/routine-exercises';
    final body = {'routine_id': routineId, 'exercise_id': exerciseId};
    final response = await NetworkService.post(url, body: body);

    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return RoutineExercise.fromJson(data);
    }
    return null;
  }

  // Listar ejercicios de una rutina
  static Future<List<Map<String, dynamic>>?> fetchExercisesOfRoutine(
    int routineId,
  ) async {
    final url = '$_baseUrl/routines/$routineId/exercises';
    final response = await NetworkService.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  // Quitar ejercicio de una rutina
  static Future<bool> removeExerciseFromRoutine(int routineExerciseId) async {
    final url = '$_baseUrl/routine-exercises/$routineExerciseId';
    final response = await NetworkService.delete(url);

    return response.statusCode == 200;
  }
}
