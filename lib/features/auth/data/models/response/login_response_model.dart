
import 'package:rentverse/features/auth/data/models/response/user_model.dart';

class LoginResponseModel {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  LoginResponseModel({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: (json['accessToken'] ?? json['token']) ?? '',
      refreshToken: json['refreshToken'] as String?,
      user: UserModel.fromJson(
        (json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': user.toJson(),
  };
}
