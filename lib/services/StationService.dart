import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';

class StationService {
	static String get _baseUrl => dotenv.env['AUTH_BASE_URL'] ?? '';

	/// Obtiene las estaciones en standby
		static Future<List<dynamic>> getStationsStandby() async {
			final url = '$_baseUrl/oauth/stations/standby';
			final response = await NetworkService.get(url);
			if (response.statusCode == 200) {
				final decoded = _decodeResponseMap(response.body);
				if (decoded != null && decoded['data'] is List) {
					return List<Map<String, dynamic>>.from(decoded['data']);
				} else {
					return [];
				}
			} else {
				throw Exception('Error al obtener estaciones en standby');
			}
		}

	/// Obtiene el usuario en standby para una estación específica
		static Future<Map<String, dynamic>?> getUserStandby(String stationToken) async {
			final url = '$_baseUrl/oauth/stations/user-standby?stationToken=$stationToken';
			final response = await NetworkService.get(url);
			if (response.statusCode == 200) {
				final decoded = _decodeResponseMap(response.body);
				if (decoded != null && decoded['data'] is Map<String, dynamic>) {
					return decoded['data'] as Map<String, dynamic>;
				} else {
					return null;
				}
			} else if (response.statusCode == 404) {
				return null;
			} else {
				throw Exception('Error al obtener usuario en standby');
			}
		}

	/// Libera la estación (acceso permitido o denegado)
	static Future<bool> releaseStandby(String stationToken, bool stationAccess) async {
		final url = '$_baseUrl/oauth/stations/release-standby?stationToken=$stationToken&stationAccess=$stationAccess';
		final response = await NetworkService.post(url);
		if (response.statusCode == 200) {
			return true;
		} else {
			return false;
		}
	}
}

List<dynamic> _decodeResponseList(String body) {
	try {
		return body.isNotEmpty ? jsonDecode(body) as List : [];
	} catch (_) {
		return [];
	}
}

Map<String, dynamic>? _decodeResponseMap(String body) {
	try {
		return body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : null;
	} catch (_) {
		return null;
	}
}
