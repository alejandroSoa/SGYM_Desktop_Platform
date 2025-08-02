import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';

class GymStatusService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Obtener registros de ocupación del gimnasio
  static Future<List<Map<String, dynamic>>?> fetchOccupancyRecords({
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '$_baseUrl/occupancy';

      // Agregar parámetros de fecha si se proporcionan
      List<String> queryParams = [];
      if (startDate != null) {
        queryParams.add('start_date=$startDate');
      }
      if (endDate != null) {
        queryParams.add('end_date=$endDate');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      print('=== GYM STATUS SERVICE DEBUG ===');
      print('URL de consulta: $url');

      final response = await NetworkService.get(url);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de registros extraída: $data');
        print('Cantidad de registros: ${data.length}');

        final result = data.cast<Map<String, dynamic>>();
        print('Resultado final: ${result.length} registros convertidos');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN GYM STATUS SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }
}
