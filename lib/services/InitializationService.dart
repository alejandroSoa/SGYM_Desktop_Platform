import 'package:shared_preferences/shared_preferences.dart';

class InitializationService {
  static const String _firstInitKey = 'first-init-app';
  
  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstInitKey) ?? false);
  }

  static Future<void> markFirstTimeDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstInitKey, true);
  }
}