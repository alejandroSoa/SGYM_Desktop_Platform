import 'package:flutter/material.dart';
import '../services/UserService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import 'dart:convert';import 'dart:html' as html;

class AuthException implements Exception {
  final String message;
  final String? details;

  AuthException(this.message, {this.details});

  @override
  String toString() {
    if (details != null) {
      return '$message\n$details';
    }
    return message;
  }
}

class AuthService {
  static Future<void> authenticateWithOAuth() async {
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }

      final authBaseUrl = dotenv.env['AUTH_BASE_URL'];
      if (authBaseUrl == null || authBaseUrl.isEmpty) {
        print('❌ AUTH_BASE_URL not found in environment variables');
        throw 'AUTH_BASE_URL not configured';
      }

      final currentUrl = html.window.location.href;
      final baseUrl = currentUrl.split('#')[0];
      final redirectUri = '${baseUrl}#/oauth-callback';

      final authUrl = Uri.parse('$authBaseUrl/oauth/login').replace(
        queryParameters: {
          'redirect_uri': redirectUri,
          'response_type': dotenv.env['OAUTH_RESPONSE_TYPE'] ?? 'token',
        },
      );

      print('🔍 Auth URL: $authUrl');
      print('🔍 Redirect URI: $redirectUri');

      // Redirigir en la misma pestaña
      html.window.location.href = authUrl.toString(); // 👈 AQUÍ EL CAMBIO
    } catch (e) {
      print('💥 Error in authenticateWithOAuth: $e');
      throw 'Error during OAuth authentication: $e';
    }
  }

    static Future<void> updateToken() async {
    final refreshToken = await UserService.getRefreshToken();

    if (refreshToken == null) {
      throw AuthException("No hay refresh token disponible");
    }

    final baseUrl = dotenv.env['AUTH_BASE_URL'];
    final fullUrl = '$baseUrl/access/refresh';

    // Enviamos el refresh token en el cuerpo de la petición
    final body = {'refresh_token': refreshToken};
    final response = await NetworkService.post(fullUrl, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['access_token'];
      final newRefreshToken = data['refresh_token'];

      if (newAccessToken != null) {
        await UserService.setToken(newAccessToken);
        print("[TOKEN_REFRESH] Access token actualizado correctamente");
      }

      if (newRefreshToken != null) {
        await UserService.setRefreshToken(newRefreshToken);
        print("[TOKEN_REFRESH] Refresh token actualizado correctamente");
      }
    } else {
      throw Exception("Error al actualizar token: ${response.body}");
    }
  }

  static Future<bool> accessByRole() async {
    final allowedRoles = [3, 5, 6];
    // final allowedRoles = ["trainer", "user", "nutritionist"];
    try {
      final userData = await UserService.getUser();

      if (userData == null) {
        throw AuthException("Usuario no autenticado");
      }

      final userRoleId = userData['role_id'];
      print("[ROLE_ID]: $userRoleId");
      // final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
      // final fullUrl = '$baseUrl/roles/$userRoleId';
      // print("[ACCESS_BY_ROLE] Verificando acceso por rol: $fullUrl");

      // final response = await NetworkService.get(fullUrl);
      // final responseData = json.decode(response.body);
      // final roleName = responseData['name'].toString();
      // print("Response body: ${response.body}");

      if (!allowedRoles.contains(userRoleId)) {
        print(
          "No está permitido el acceso a la aplicación desde este dispositivo.",
        );
        throw AuthException(
          "Acceso denegado: Tu rol no tiene acceso a la aplicación desde este dispositivo.",
        );
      }

      return true;
    } catch (e) {
      print("[ACCESS_BY_ROLE] Error: $e");
      return false;
    }
  }

  static Future<int?> getCurrentUserRole() async {
    try {
      final userData = await UserService.getUser();
      if (userData == null) return null;

      final userRoleId = userData['role_id'];
      print("[GET_CURRENT_ROLE] Role ID: $userRoleId");
      return userRoleId is int
          ? userRoleId
          : int.tryParse(userRoleId.toString());
    } catch (e) {
      print("[GET_CURRENT_ROLE] Error: $e");
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await UserService.getRefreshToken();
    } catch (e) {
      print("[GET_REFRESH_TOKEN] Error: $e");
      return null;
    }
  }
}
