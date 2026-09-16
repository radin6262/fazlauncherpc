import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _bgKey = 'background_image';

  static Future<String?> getBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bgKey);
  }

  static Future<void> setBackgroundImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bgKey, path);
  }
}
