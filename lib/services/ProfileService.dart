import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interfaces/user/profile_interface.dart';
import 'UserService.dart';

class ProfileService {
  static Future<Profile?> fetchProfile([int? userId]) async {
    final token = await UserService.getToken();
    if (token == null) return null;

    final idPath = userId != null ? userId.toString() : '';

    final response = await http.get(
      Uri.parse('https://localhost:3333/users/$idPath/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Profile.fromJson(data['data']);
    } else {
      return null;
    }
  }
}