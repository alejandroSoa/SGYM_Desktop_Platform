import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interfaces/bussiness/report_interface.dart';

class ReportService {
	static const String baseUrl = 'http://146.190.130.50/api/accesses';

	static Future<List<ReportAccess>> getAccesses({
		String? date,
		String? startTime,
		String? endTime,
	}) async {
		final queryParams = <String, String>{};
		if (date != null) queryParams['date'] = date;
		if (startTime != null) queryParams['startTime'] = startTime;
		if (endTime != null) queryParams['endTime'] = endTime;

		final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
		final response = await http.get(uri);

		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			if (data['status'] == 'success' && data['data'] is List) {
				return (data['data'] as List)
						.map((item) => ReportAccess.fromJson(item as Map<String, dynamic>))
						.toList();
			} else {
				throw Exception(data['msg'] ?? 'Error en la respuesta');
			}
		} else {
			throw Exception('Error de red: ${response.statusCode}');
		}
	}
}
