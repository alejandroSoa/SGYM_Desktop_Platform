import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interfaces/user/profile_interface.dart';
import 'UserService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/NetworkService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileService {
  static const String _profileKey = 'user_profile';

  static Future<void> setProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode({
      'user_id': profile.userId,
      'full_name': profile.fullName,
      'phone': profile.phone,
      'birth_date': profile.birthDate,
      'gender': profile.gender,
      'photo_url': profile.photoUrl,
    }));
  }

  static Future<Profile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson == null) return null;
    return Profile.fromJson(json.decode(profileJson));
  }


  static Future<Profile?> fetchProfile([int? userId]) async {
    final token = await UserService.getToken();
    if (token == null) return null;

    int? idToUse = userId;
    if (idToUse == null) {
      final user = await UserService.getUser();
      idToUse = user?['id'];
    }
    if (idToUse == null) return null;

    // Usa la URL base del .env
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: ".env");
    }
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return null;

    final url = '${baseUrl}users/$idToUse/profile';

    final response = await NetworkService.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final profile = Profile.fromJson(data['data']);
      return profile;
    } else {
      return null;
    }
  }

    /// Servicio: Actualizar perfil de usuario
    static Future<Profile?> createProfile({
      required int userId,
      required String fullName,
      required String phone,
      required String birthDate,
      required String gender,
      String? photoUrl,
    }) async {
      final token = await UserService.getToken();
      if (token == null) return null;

      final body = {
        'user_id': userId,
        'full_name': fullName,
        'phone': phone,
        'birth_date': birthDate,
        'gender': gender,
        if (photoUrl != null) 'photo_url': photoUrl,
      };

      final response = await http.post(
        Uri.parse('https://localhost:3333/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Profile.fromJson(data['data']);
      } else {
        return null;
      }
  }


    /// Servicio: Eliminar perfil de usuario por ID
  static Future<bool> deleteProfile(int userId) async {
    final token = await UserService.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('https://localhost:3333/users/$userId/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true; // Eliminación exitosa
    } else {
      return false; // Error o no encontrado
    }
  }
}