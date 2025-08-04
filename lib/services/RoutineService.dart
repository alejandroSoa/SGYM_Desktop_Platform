import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../interfaces/bussiness/routine_excersice_interface.dart';
import '../network/NetworkService.dart';
import 'UserService.dart';

class RoutineService {
  static String get _baseUrl {
    final url = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Listar rutinas
  static Future<List<Routine>> fetchRoutines() async {
    try {
      final url = '$_baseUrl/routines';
      print('Fetching routines from: $url');
      final response = await NetworkService.get(url);
      final responseData = json.decode(response.body);
      print('Response data: $responseData');
      final data = responseData['data'] as List;
      return data
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => Routine.fromJson(e as Map<String, dynamic>))
          .toList();
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
    required String name,
    String? description,
    required int userId,
  }) async {
    try {
      final url = '$_baseUrl/routines';
      final body = {
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
    required String name,
    String? description,
  }) async {
    final url = '$_baseUrl/routines/$id';
    final body = {'name': name, 'description': description};
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
    print('Fetching exercises for routine ID $routineId from: $url');
    final response = await NetworkService.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      print(data);
      // Adaptar para devolver una lista de mapas planos con routine_exercise_id y los datos del ejercicio
      return data.map((e) {
        final relationId = e['id'];
        final exercise = Map<String, dynamic>.from(e['exercise'] ?? {});
        return <String, dynamic>{
          'routine_exercise_id': relationId,
          ...exercise
        };
      }).toList();
    }
    return null;
  }

  // Quitar ejercicio de una rutina
  Future<bool> removeExerciseFromRoutine(int routineExerciseId) async {
    final url = '$_baseUrl/routine-exercises/$routineExerciseId';
    print('[REMOVE_EXERCISE] Intentando eliminar con URL: $url');
    final response = await NetworkService.delete(url);
    if (response.statusCode != 200) {
      print('[REMOVE_EXERCISE] Falló la eliminación. Status: ${response.statusCode}, Body: ${response.body}');
    }
    return response.statusCode == 200;
  }

    // Asignar rutina a usuario
  static Future<Map<String, dynamic>?> assignRoutineToUser({
    required int userId,
    required int routineId,
    required String day,
  }) async {
    final url = '$_baseUrl/user-routines';
    final body = {
      'user_id': userId,
      'routine_id': routineId,
      'day': day,
    };
    print('[ASSIGN_ROUTINE_TO_USER] POST $url');
    print('[ASSIGN_ROUTINE_TO_USER] Body: $body');
    final response = await NetworkService.post(url, body: body);
    print('[ASSIGN_ROUTINE_TO_USER] Status: ${response.statusCode}');
    print('[ASSIGN_ROUTINE_TO_USER] Response: ${response.body}');
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}

