

import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/features/auth/domain/entity/login_request_entity.dart';
import 'package:rentverse/features/auth/domain/entity/register_request_enity.dart';
import 'package:rentverse/features/auth/domain/entity/user_entity.dart';
import 'package:rentverse/features/auth/domain/entity/update_profile_request_entity.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> login(LoginRequestEntity params);
  Future<DataState<UserEntity>> register(RegisterRequestEntity params);
  Future<DataState<UserEntity>> getUserProfile();
  Future<DataState<UserEntity>> updateProfile(
    UpdateProfileRequestEntity params,
  );
  Future<DataState<bool>> sendOtp({
    required String target,
    required String channel,
  });
  Future<DataState<bool>> verifyOtp({
    required String target,
    required String channel,
    required String code,
  });
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getLastLocalUser();
  Future<DataState<String>> refreshToken();
}
