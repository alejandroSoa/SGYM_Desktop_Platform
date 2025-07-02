import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:html' as html;

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
}
