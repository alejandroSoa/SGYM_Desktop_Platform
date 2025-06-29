import 'package:flutter/material.dart';
import 'package:sgym/services/InitializationService.dart';
import '../services/UserService.dart';
import '../main.dart';
import 'dart:html' as html;

class OAuthCallbackScreen extends StatefulWidget {
  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleRedirect();
  }

  Future<void> _handleRedirect() async {
    final uri = Uri.base;
    print('URI base: $uri');
    print('Query parameters: ${uri.queryParameters}');

    // Extraer el token de los parámetros de la query
    String? token = uri.queryParameters['access_token'];

    if (token != null && token.isNotEmpty) {
      await UserService.setToken(token);
      //await UserService.fetchUser();

      // Limpiar la URL de la barra de direcciones sin recargar la página
      html.window.history.replaceState(
        null, 
        'OAuth Redirect', 
        html.window.location.pathname
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainLayout()),
        );
      }
    } else {
      print("No se encontró el token en la redirección.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

