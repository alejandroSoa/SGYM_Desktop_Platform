import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/bussiness/excersice_interface.dart';

class ExerciseService {
  static const String _logTag = "[EXERCISE_SERVICE]";
  static String get baseUrl {
    final url = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  /// Obtiene todos los ejercicios disponibles
  static Future<List<Exercise>> getExercises() async {
    try {
      final fullUrl = '$baseUrl/exercises';

      print("$_logTag Cargando ejercicios desde: $fullUrl");

      final response = await NetworkService.get(fullUrl);

      print("$_logTag Response status: ${response.statusCode}");
      print("$_logTag Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exercisesData = data['data'] ?? data;

        List<Exercise> exercises = [];

        if (exercisesData is List) {
          exercises = exercisesData
              .map((exerciseData) => Exercise.fromJson(exerciseData))
              .toList();
        } else if (exercisesData is Map) {
          exercises = [
            Exercise.fromJson(exercisesData.cast<String, dynamic>()),
          ];
        }

        print("$_logTag Ejercicios cargados: ${exercises.length}");
        return exercises;
      } else {
        throw Exception('Error al cargar ejercicios: ${response.statusCode}');
      }
    } catch (e) {
      print("$_logTag Error: $e");
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene un ejercicio específico por su ID
  static Future<Exercise> getExerciseById(int id) async {
    try {
      final fullUrl = '$baseUrl/exercises/$id';

      print("$_logTag Obteniendo ejercicio desde: $fullUrl");

      final response = await NetworkService.get(fullUrl);

      print("$_logTag Get Exercise Response status: ${response.statusCode}");
      print("$_logTag Get Exercise Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exerciseData = data['data'] ?? data;

        return Exercise.fromJson(exerciseData);
      } else {
        throw Exception('Error al obtener ejercicio: ${response.statusCode}');
      }
    } catch (e) {
      print("$_logTag Error getting exercise by ID: $e");
      throw Exception('Error de conexión: $e');
    }
  }

  /// Crea un nuevo ejercicio
  static Future<Exercise> createExercise({
    required String name,
    required String description,
    required EquipmentType equipmentType,
    required String videoUrl,
  }) async {
    try {
      final fullUrl = '$baseUrl/exercises';

      print("$_logTag Creando ejercicio en: $fullUrl");

      final body = {
        'name': name,
        'description': description,
        'equipment_type': equipmentType.value,
        'video_url': videoUrl,
      };

      print("$_logTag Body del POST: $body");

      final response = await NetworkService.post(fullUrl, body: body);

      print("$_logTag Create Response status: ${response.statusCode}");
      print("$_logTag Create Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final exerciseData = data['data'] ?? data;
        return Exercise.fromJson(exerciseData);
      } else {
        throw Exception('Error al crear ejercicio: ${response.statusCode}');
      }
    } catch (e) {
      print("$_logTag Error creating exercise: $e");
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualiza un ejercicio existente
  static Future<Exercise> updateExercise({
    required int id,
    required String name,
    required String description,
    required EquipmentType equipmentType,
    required String videoUrl,
  }) async {
    try {
      final fullUrl = '$baseUrl/exercises/$id';

      print("$_logTag Actualizando ejercicio en: $fullUrl");

      final body = {
        'name': name,
        'description': description,
        'equipment_type': equipmentType.value,
        'video_url': videoUrl,
      };

      print("$_logTag Body del PUT: $body");

      final response = await NetworkService.put(fullUrl, body: body);

      print("$_logTag Update Response status: ${response.statusCode}");
      print("$_logTag Update Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exerciseData = data['data'] ?? data;
        return Exercise.fromJson(exerciseData);
      } else {
        throw Exception(
          'Error al actualizar ejercicio: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("$_logTag Error updating exercise: $e");
      throw Exception('Error de conexión: $e');
    }
  }

  /// Elimina un ejercicio
  static Future<bool> deleteExercise(int id) async {
    try {
      final fullUrl = '$baseUrl/exercises/$id';

      print("$_logTag Eliminando ejercicio en: $fullUrl");

      final response = await NetworkService.delete(fullUrl);

      print("$_logTag Delete Response status: ${response.statusCode}");
      print("$_logTag Delete Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar ejercicio: ${response.statusCode}');
      }
    } catch (e) {
      print("$_logTag Error deleting exercise: $e");
      throw Exception('Error de conexión: $e');
    }
  }

  /// Filtra ejercicios por búsqueda
  static List<Exercise> filterExercises(
    List<Exercise> exercises,
    String query,
  ) {
    if (query.isEmpty) {
      return exercises;
    }

    final searchQuery = query.toLowerCase();
    return exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(searchQuery) ||
          exercise.description.toLowerCase().contains(searchQuery) ||
          exercise.equipmentType.displayName.toLowerCase().contains(
            searchQuery,
          );
    }).toList();
  }

  /// Obtiene ejercicios por tipo de equipamiento
  static List<Exercise> getExercisesByType(
    List<Exercise> exercises,
    EquipmentType type,
  ) {
    return exercises
        .where((exercise) => exercise.equipmentType == type)
        .toList();
  }
}
