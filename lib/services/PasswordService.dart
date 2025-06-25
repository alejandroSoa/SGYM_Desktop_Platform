import 'dart:convert';
import 'package:http/http.dart' as http;
import 'UserService.dart';

class PasswordService {
  static const String _baseUrl = 'http://localhost:3333';

  // Recuperar contraseña (Forgot Password)
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }

  // Restablecer contraseña (Reset Password)
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }

  // Cambiar contraseña (Change Password)
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final token = await UserService.getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );
    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }
}