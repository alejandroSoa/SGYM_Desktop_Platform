import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
    static Future<void> authenticateWithOAuth() async {
      const redirectUri = 'http://localhost:54589/#/oauth-callback';
      final authUrl = Uri.https(
        'be23-2806-267-1482-1823-4104-245b-590a-3de7.ngrok-free.app',
        '/oauth/login',
        {
          'redirect_uri': redirectUri,
          'response_type': 'token',
        },
      );

      if (!await launchUrl(authUrl, mode: LaunchMode.platformDefault)) {
        throw 'No se pudo abrir la URL de autenticación';
      }
    }
}