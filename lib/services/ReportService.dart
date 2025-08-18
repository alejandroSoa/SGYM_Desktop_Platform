import 'dart:convert';
import '../interfaces/bussiness/report_interface.dart';
import '../network/NetworkService.dart';

class ReportService {
	static const String baseUrl = 'http://143.110.150.81/accesses'; // from .env BUSINESS_BASE_URL

	static Future<List<ReportAccess>> getAccesses({
		String? date,
		String? startTime,
		String? endTime,
	}) async {
		final queryParams = <String, String>{};
		if (date != null) queryParams['date'] = date;
		if (startTime != null) queryParams['start_time'] = startTime;
		if (endTime != null) queryParams['end_time'] = endTime;

		final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
		final response = await NetworkService.get(uri.toString());

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
