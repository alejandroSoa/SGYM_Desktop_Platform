import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String _tokenKey = 'auth_token';
  static const String _baseUrl = 'http://localhost:3333';

  // Guarda el token en SharedPreferences
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Obtiene el token de SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Elimina el token (opcional)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user));
  }

  // Obtiene el usuario de SharedPreferences
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson == null) return null;
    return json.decode(userJson) as Map<String, dynamic>;
  }

  // Servicio: Obtener datos de un usuario
  static Future<Map<String, dynamic>?> fetchUser([int? userId]) async {
    final token = await getToken();
    if (token == null) return null;
  
    final url = userId != null 
        ? '$_baseUrl/users/${userId.toString()}'
        : '$_baseUrl/users';
  
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  
    if (response.statusCode == 200) {
        setUser(json.decode(response.body)['data']);
    } else {
      return null;
    }
  }

  /// Servicio: Actualizar datos de un usuario
  static Future<Map<String, dynamic>?> updateUser({
    required int userId,
    String? email,
    int? roleId,
    bool? isActive,
  }) async {
    final token = await getToken();
    if (token == null) return null;

    // Construye el body solo con los campos permitidos
    final Map<String, dynamic> body = {};
    if (email != null) body['email'] = email;
    if (roleId != null) body['role_id'] = roleId;
    if (isActive != null) body['is_active'] = isActive;

    final response = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      // Puedes agregar manejo de errores aquí si lo deseas
      return null;
    }
  }

  /// Servicio: Eliminar usuario por ID
  static Future<Map<String, dynamic>?> deleteUser(int userId) async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Usuario no encontrado
      return json.decode(response.body);
    } else {
      // Otro error
      return null;
    }
  }

  }