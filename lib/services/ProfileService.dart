import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interfaces/user/profile_interface.dart';
import 'UserService.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final User = await UserService.getUser();

    if (token == null) return null;

    final idPath = User?['id'];
    final url = 'https://2886-2806-101e-b-bea-14c6-f2f4-c351-92f7.ngrok-free.app/users/$idPath/profile';
    //    final url = 'https://2886-2806-101e-b-bea-14c6-f2f4-c351-92f7.ngrok-free.app/users/6/profile';

    final response = await http.get(
        Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        //Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjYsImVtYWlsIjoidGlvLm1hbmNvLjIyMTJAZ21haWwuY29tIiwicm9sZUlkIjoxLCJpYXQiOjE3NTA4NzIyNTgsImV4cCI6MTc1MDg3NTg1OH0.73yqs-nM0M--wgJCoxM5SPXzKNaBRyRY7P8PZ1kyN0k',

        'Content-Type': 'application/json',
      },
    );


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