import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:html' as html;

class AuthService {
  static Future<void> authenticateWithOAuth() async {
    try {
      // Load dotenv if not already loaded
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }
      
      final authBaseUrl = dotenv.env['AUTH_BASE_URL'];
      
      if (authBaseUrl == null || authBaseUrl.isEmpty) {
        print('❌ AUTH_BASE_URL not found in environment variables');
        throw 'AUTH_BASE_URL not configured';
      }

      // Get current URL for dynamic redirect URI
      final currentUrl = html.window.location.href;
      final baseUrl = currentUrl.split('#')[0]; // Remove any fragment
      final redirectUri = '${baseUrl}#/oauth-callback';
      
      final authUrl = Uri.parse('$authBaseUrl/oauth/login').replace(
        queryParameters: {
          'redirect_uri': redirectUri,
          'response_type': dotenv.env['OAUTH_RESPONSE_TYPE'] ?? 'token',
        },
      );

      print('🔍 Auth URL: $authUrl');
      print('🔍 Redirect URI: $redirectUri');

      if (!await launchUrl(authUrl, mode: LaunchMode.platformDefault)) {
        throw 'No se pudo abrir la URL de autenticación';
      }
    } catch (e) {
      print('💥 Error in authenticateWithOAuth: $e');
      throw 'Error during OAuth authentication: $e';
    }
  }
}