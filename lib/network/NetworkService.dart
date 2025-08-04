import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/UserService.dart';
import '../services/AuthService.dart';

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
    http.Response response = await http.get(
      Uri.parse(fullUrl),
      headers: requestHeaders,
    );
    if (response.statusCode == 401) {
      try {
        await AuthService.updateToken();
        final retryHeaders = await _getHeaders(additionalHeaders: headers);
        response = await http.get(
          Uri.parse(fullUrl),
          headers: retryHeaders,
        );
      } catch (e) {
        // Si falla el refresh, simplemente retorna el 401 original
      }
    }
    return response;
  }

  static Future<http.Response> post(
    String fullUrl, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    http.Response response = await http.post(
      Uri.parse(fullUrl),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
    if (response.statusCode == 401) {
      try {
        await AuthService.updateToken();
        final retryHeaders = await _getHeaders(additionalHeaders: headers);
        response = await http.post(
          Uri.parse(fullUrl),
          headers: retryHeaders,
          body: body != null ? json.encode(body) : null,
        );
      } catch (e) {}
    }
    return response;
  }

  static Future<http.Response> put(
    String fullUrl, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    http.Response response = await http.put(
      Uri.parse(fullUrl),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
    if (response.statusCode == 401) {
      try {
        await AuthService.updateToken();
        final retryHeaders = await _getHeaders(additionalHeaders: headers);
        response = await http.put(
          Uri.parse(fullUrl),
          headers: retryHeaders,
          body: body != null ? json.encode(body) : null,
        );
      } catch (e) {}
    }
    return response;
  }

  static Future<http.Response> putWithBody(
    String fullUrl,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    http.Response response = await http.put(
      Uri.parse(fullUrl),
      headers: requestHeaders,
      body: json.encode(body),
    );
    if (response.statusCode == 401) {
      try {
        await AuthService.updateToken();
        final retryHeaders = await _getHeaders(additionalHeaders: headers);
        response = await http.put(
          Uri.parse(fullUrl),
          headers: retryHeaders,
          body: json.encode(body),
        );
      } catch (e) {}
    }
    return response;
  }

  static Future<http.Response> delete(String fullUrl, {Map<String, String>? headers}) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    http.Response response = await http.delete(
      Uri.parse(fullUrl),
      headers: requestHeaders,
    );
    if (response.statusCode == 401) {
      try {
        await AuthService.updateToken();
        final retryHeaders = await _getHeaders(additionalHeaders: headers);
        response = await http.delete(
          Uri.parse(fullUrl),
          headers: retryHeaders,
        );
      } catch (e) {}
    }
    return response;
  }

  static Future<http.Response> patch(
    String fullUrl, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    http.Response response = await http.patch(
      Uri.parse(fullUrl),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
    if (response.statusCode == 401) {
      try {
        await AuthService.updateToken();
        final retryHeaders = await _getHeaders(additionalHeaders: headers);
        response = await http.patch(
          Uri.parse(fullUrl),
          headers: retryHeaders,
          body: body != null ? json.encode(body) : null,
        );
      } catch (e) {}
    }
    return response;
  }
}