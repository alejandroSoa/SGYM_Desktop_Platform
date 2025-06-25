import 'dart:convert';
import 'package:http/http.dart' as http;
import 'UserService.dart';

class QrService {
  static const String _baseUrl = 'http://localhost:3333';

  static Future<Map<String, dynamic>?> generateQr(int userId) async {
    final token = await UserService.getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/users/$userId/qr'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return json.decode(response.body)['data'];
    } else {
      return null;
    }
  }
}