import 'dart:convert';
import '../interfaces/user/profile_interface.dart';
import '../interfaces/user/qr_interface.dart';
import 'UserService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
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

  static Future<Profile?> updateProfile(Profile currentProfile, {
    String? fullName,
    String? phone,
    String? birthDate,
    String? gender,
    String? photoUrl,
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

  static Future<void> updatePassword(String currentPassword, String newPassword, String confirmPassword) async {
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

  static Future<QrCode?> fetchQrCode() async {
    final User = await UserService.getUser();

    final idPath = await User?['id'];
    final baseUrl = dotenv.env['AUTH_BASE_URL'];
    final fullUrl = '$baseUrl/users/$idPath/qr';
    
    final response = await NetworkService.post(fullUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final qr = QrCode.fromJson(data['data']);
        return qr;
      } else {
        throw Exception(response.body);
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