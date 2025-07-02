import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/UserService.dart';

class NetworkService {

  //To-Do Agregar que en caso de que haya token pero sea invalido se actualice

  static Future<Map<String, String>> _getHeaders({Map<String, String>? additionalHeaders}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final token = await UserService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  static Future<http.Response> get(String fullUrl, {Map<String, String>? headers}) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    
    return await http.get(
      Uri.parse(fullUrl),
      headers: requestHeaders,
    );
  }

  static Future<http.Response> post(
    String fullUrl, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    
    return await http.post(
      Uri.parse(fullUrl),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
  }

  static Future<http.Response> put(
    String fullUrl, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    
    return await http.put(
      Uri.parse(fullUrl),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
  }

  static Future<http.Response> delete(String fullUrl, {Map<String, String>? headers}) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    
    return await http.delete(
      Uri.parse(fullUrl),
      headers: requestHeaders,
    );
  }

  static Future<http.Response> patch(
    String fullUrl, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    
    return await http.patch(
      Uri.parse(fullUrl),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
  }
}