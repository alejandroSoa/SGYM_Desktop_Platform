import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../interfaces/files/file_interface.dart';
import '../network/NetworkService.dart';

class FileService {
  /// Listar archivos con filtros opcionales
  ///
  /// [type] - Filtrar por tipo de archivo (opcional, ej: "diet_plan")
  /// [relatedId] - Filtrar por ID relacionado (opcional)
  ///
  /// Returns [FileListResponse] con la lista de archivos
  static Future<FileListResponse> getFiles({
    String? type,
    int? relatedId,
  }) async {
    try {
      final baseUrl = dotenv.env['FILE_STORAGE_BASE_URL'];

      // Construir URL con query parameters
      String fullUrl = '$baseUrl/files';
      List<String> queryParams = [];

      if (type != null && type.isNotEmpty) {
        queryParams.add('type=$type');
      }
      if (relatedId != null) {
        queryParams.add('related_id=$relatedId');
      }

      if (queryParams.isNotEmpty) {
        fullUrl += '?${queryParams.join('&')}';
      }

      print('Obteniendo archivos desde: $fullUrl'); // Debug log

      final response = await NetworkService.get(fullUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
          'Archivos obtenidos: ${data['data'].length} encontrados',
        ); // Debug log
        return FileListResponse.fromJson(data);
      } else {
        print('Error al obtener archivos: ${response.body}'); // Debug log
        throw Exception(response.body);
      }
    } catch (e) {
      print('Excepción en getFiles: $e'); // Debug log
      throw e;
    }
  }

  /// Descargar archivo por ID
  ///
  /// [fileId] - ID del archivo a descargar
  ///
  /// Returns [Uint8List] con los bytes del archivo descargado
  static Future<Uint8List> downloadFile(int fileId) async {
    try {
      final baseUrl = dotenv.env['FILE_STORAGE_BASE_URL'];
      final fullUrl = '$baseUrl/files/$fileId/download';

      print('Descargando archivo desde: $fullUrl'); // Debug log

      final response = await NetworkService.get(fullUrl);

      if (response.statusCode == 200) {
        print(
          'Archivo descargado exitosamente. Tamaño: ${response.bodyBytes.length} bytes',
        ); // Debug log
        return response.bodyBytes;
      } else {
        print('Error al descargar archivo: ${response.body}'); // Debug log
        throw Exception(response.body);
      }
    } catch (e) {
      print('Excepción en downloadFile: $e'); // Debug log
      throw e;
    }
  }

  /// Eliminar archivo por ID
  ///
  /// [fileId] - ID del archivo a eliminar
  ///
  /// Returns [FileDeleteResponse] confirmando la eliminación
  static Future<FileDeleteResponse> deleteFile(int fileId) async {
    try {
      final baseUrl = dotenv.env['FILE_STORAGE_BASE_URL'];
      final fullUrl = '$baseUrl/files/$fileId';

      print('Eliminando archivo: $fullUrl'); // Debug log

      final response = await NetworkService.delete(fullUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
          'Archivo eliminado exitosamente: ID ${data['data']['id']}',
        ); // Debug log
        return FileDeleteResponse.fromJson(data);
      } else {
        print('Error al eliminar archivo: ${response.body}'); // Debug log
        throw Exception(response.body);
      }
    } catch (e) {
      print('Excepción en deleteFile: $e'); // Debug log
      throw e;
    }
  }
}
