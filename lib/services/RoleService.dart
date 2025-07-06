import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';

class RoleService {
  static Future<List<Map<String, dynamic>>> getRoles() async {
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'] ?? '';
    final url = '$baseUrl/roles';

    final response = await NetworkService.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResp = json.decode(response.body);
      if (jsonResp['status'] == 'success' && jsonResp['data'] is List<dynamic>) {
        return (jsonResp['data'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      throw Exception(jsonResp['msg'] ?? 'Error desconocido al obtener roles');
    } else {
      throw Exception('Error al obtener roles: ${response.statusCode}');
    }
  }
}



