import 'package:flutter/material.dart';
import '../services/UserService.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

class SubscriptionWebView extends StatefulWidget {
  final Function(Map<String, dynamic>?) onResult;

  const SubscriptionWebView({super.key, required this.onResult});

  @override
  State<SubscriptionWebView> createState() => _SubscriptionWebViewState();
}

class _SubscriptionWebViewState extends State<SubscriptionWebView> {
  bool _isLoading = true;
  String? _errorMessage;
  Webview? _desktopWebview;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      final token = await UserService.getToken();
      final baseUrl = '146.190.130.50';
      String url = token != null
          ? 'http://$baseUrl/federation-login?access_token=$token'
          : 'http://$baseUrl/federation-login';

      _desktopWebview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          windowHeight: 700,
          windowWidth: 500,
          title: "Suscripción SGym",
        ),
      );
      _desktopWebview!
        ..setApplicationNameForUserAgent("SGymDesktop/1.0.0")
        ..addOnUrlRequestCallback((url) {
          print('🔗 DesktopWebview navegando a: $url');
        })
        ..launch(url);

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al inicializar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción - SGym'),
        backgroundColor: const Color(0xFF7012DA),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _isLoading = true;
                      });
                      _initializeWebView();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7012DA),
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          if (_isLoading && _errorMessage == null)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7012DA),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando página de suscripción...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF7012DA)),
                  ),
                ],
              ),
            ),
          // En desktop, el WebView se muestra en ventana aparte, así que no se muestra aquí
        ],
      ),
    );
  }
}