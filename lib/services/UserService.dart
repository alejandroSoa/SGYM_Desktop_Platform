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

  // Servicio: Obtener datos de un usuario
  static Future<Map<String, dynamic>?> fetchUser([int? userId]) async {
    final token = await getToken();
    if (token == null) return null;
  
    // Si no se pasa userId, usa 'me' para obtener el usuario autenticado
    final idPath = userId != null ? userId.toString() : '';
  
    final response = await http.get(
      Uri.parse('http://$_baseUrl/users/$idPath'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      return null;
    }
  }

  }