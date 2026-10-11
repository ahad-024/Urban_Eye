import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'urbaneye_access_token';
  static const String _refreshTokenKey = 'urbaneye_refresh_token';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _accessTokenKey,
      accessToken,
    );

    await prefs.setString(
      _refreshTokenKey,
      refreshToken,
    );
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_refreshTokenKey);
  }

  static Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    return accessToken != null &&
        refreshToken != null &&
        accessToken.isNotEmpty &&
        refreshToken.isNotEmpty;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}