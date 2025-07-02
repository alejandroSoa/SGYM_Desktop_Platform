import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../network/NetworkService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../interfaces/user/user_interface.dart';

class UserService {
  static const String _tokenKey = 'oauth-token';

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson == null) return null;
    return json.decode(userJson) as Map<String, dynamic>?;
  }

  static Future<dynamic> fetchUser([int? userId]) async {
    try {
      // Load dotenv if not already loaded
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }
      
      final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
      
      if (baseUrl == null || baseUrl.isEmpty) {
        print('❌ BUSINESS_BASE_URL not found in environment variables');
        return null;
      }
      
      final fullUrl = userId != null 
          ? '${baseUrl}users/${userId.toString()}'
          : '${baseUrl}users';

      print('🔍 Fetching users from: $fullUrl');

      final response = await NetworkService.get(fullUrl);

      print('📡 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body)['data'];
        
        print('📊 Response data type: ${responseData.runtimeType}');
        print('📊 Response data: $responseData');
        
        if (responseData is List) {
          print('✅ Returning list of ${responseData.length} users');
          return responseData.map((userJson) => User.fromJson(userJson as Map<String, dynamic>)).toList();
        }
        
        if (responseData is Map<String, dynamic>) {
          print('✅ Converting single user to list');
          final user = User.fromJson(responseData);
          return [user];
        }
        
        print('❌ Response data format not recognized');
        return null;
      } else {
        print('❌ Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Error in fetchUser: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateUser({
    required int userId,
    String? email,
    int? roleId,
    bool? isActive,
  }) async {
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }
      
      final baseUrl = dotenv.env['BUSINESS_BASE_URL'];

      final Map<String, dynamic> body = {};
      if (email != null) body['email'] = email;
      if (roleId != null) body['role_id'] = roleId;
      if (isActive != null) body['is_active'] = isActive;
      
      final fullUrl = '${baseUrl}users/${userId.toString()}';

      print('🔄 Updating user at: $fullUrl');
      print('📝 Update body: $body');

      final response = await NetworkService.putWithBody(fullUrl, body);

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      } else {
        print('❌ Update failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Error in updateUser: $e');
      return null;
    }
  }


  }