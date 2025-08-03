import 'dart:convert';
import 'package:sgym/interfaces/user/qr_interface.dart';
import '../interfaces/user/profile_interface.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/UserService.dart';

class ProfileService {
  static const String _profileKey = 'profile';

  static Future<Profile?> fetchProfileByUserId(int userId) async {
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
    final fullUrl = '$baseUrl/users/$userId/profile';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Profile.fromJson(data['data']);
    } else {
      return null;
    }
  }

  static Future<Profile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson == null) return null;
    return Profile.fromJson(json.decode(profileJson));
  }

  static Future<Profile?> fetchProfile() async {
    final User = await UserService.getUser();

    final idPath = await User?['id'];
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
    final fullUrl = '$baseUrl/users/$idPath/profile';

    final response = await NetworkService.get(fullUrl);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final profile = Profile.fromJson(data['data']);

      return profile;
    } else {
      return null;
    }
  }

  static Future<Profile?> updateProfile(
    Profile currentProfile, {
    String? fullName,
    String? phone,
    String? birthDate,
    String? gender,
    String? photoUrl, required int userId,
  }) async {
    final user = await UserService.getUser();
    final idPath = await user?['id'];
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
    final fullUrl = '$baseUrl/users/$idPath/profile';
    final body = {
      'full_name': fullName ?? currentProfile.fullName,
      'phone': phone ?? currentProfile.phone,
      'birth_date': birthDate ?? currentProfile.birthDate,
      'gender': gender ?? currentProfile.gender,
      'photo_url': photoUrl ?? currentProfile.photoUrl,
    };

    final response = await NetworkService.put(fullUrl, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Profile.fromJson(data['data']);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<void> updatePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final baseUrl = dotenv.env['AUTH_BASE_URL'];
    final fullUrl = '$baseUrl/auth/change-password';

    final body = {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    };

    final response = await NetworkService.put(fullUrl, body: body);

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<QrCode?> fetchQrCode() async {
    try {
      final User = await UserService.getUser();
      final idPath = await User?['id'];
      final baseUrl = dotenv.env['AUTH_BASE_URL'];
      final fullUrl = '$baseUrl/users/$idPath/qr';

      print('Haciendo petición POST a: $fullUrl'); // Debug log
      final response = await NetworkService.post(fullUrl);
      print(
        'Respuesta recibida. Status code: ${response.statusCode}',
      ); // Debug log
      print('Response body length: ${response.body.length}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Parseando respuesta JSON...'); // Debug log
        final data = json.decode(response.body);
        print('JSON parseado. Status: ${data['status']}'); // Debug log

        if (data['status'] == 'success' && data['data'] != null) {
          print('Creando QrCode desde JSON...'); // Debug log
          final qr = QrCode.fromJson(data['data']);
          print(
            'QrCode creado exitosamente. Base64 length: ${qr.qr_image_base64.length}',
          ); // Debug log
          return qr;
        } else {
          print(
            'Error en la respuesta: ${data['msg'] ?? 'Error desconocido'}',
          ); // Debug log
          throw Exception(response.body);
        }
      } else {
        print('Error HTTP: ${response.statusCode}'); // Debug log
        throw Exception(response.body);
      }
    } catch (e) {
      print('Excepción en fetchQrCode: $e'); // Debug log
      throw e; // Re-lanzar la excepción para que la maneje el código llamador
    }
  }

  //Probar funcionalidad
  static Future<Profile?> createProfile({
    required int userId,
    required String fullName,
    required String phone,
    required String birthDate,
    required String gender,
    String? photoUrl,
  }) async {
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
    final fullUrl = '$baseUrl/users/profile';

    final body = {
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'birth_date': birthDate,
      'gender': gender,
      if (photoUrl != null) 'photo_url': photoUrl,
    };

    final response = await NetworkService.post(fullUrl, body: body);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Profile.fromJson(data['data']);
    } else {
      return null;
    }
  }
}
