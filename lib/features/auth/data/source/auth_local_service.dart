import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constant/api_urls.dart';
import '../models/response/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<String?> getRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  static const String CACHED_USER_KEY = 'CACHED_USER_DATA';
  static const String TOKEN_KEY = ApiConstants.tokenKey;
  static const String REFRESH_TOKEN_KEY = ApiConstants.refreshTokenKey;

  AuthLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString(TOKEN_KEY, token);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _sharedPreferences.setString(TOKEN_KEY, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _sharedPreferences.setString(REFRESH_TOKEN_KEY, refreshToken);
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _sharedPreferences.setString(CACHED_USER_KEY, jsonString);
  }

  @override
  Future<UserModel?> getLastUser() async {
    final jsonString = _sharedPreferences.getString(CACHED_USER_KEY);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(jsonString));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = _sharedPreferences.getString(TOKEN_KEY);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    await Future.wait([
      _sharedPreferences.remove(CACHED_USER_KEY),
      _sharedPreferences.remove(TOKEN_KEY),
      _sharedPreferences.remove(REFRESH_TOKEN_KEY),
    ]);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _sharedPreferences.getString(REFRESH_TOKEN_KEY);
  }
}
