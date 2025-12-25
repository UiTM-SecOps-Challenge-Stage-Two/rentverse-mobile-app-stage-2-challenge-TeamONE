

import 'package:dio/dio.dart';
import 'package:rentverse/features/auth/data/source/auth_local_service.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entity/login_request_entity.dart';
import '../../domain/entity/register_request_enity.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/entity/update_profile_request_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../models/request/login_request_model.dart';
import '../models/request/register_request_model.dart';
import '../models/request/update_profile_request_model.dart';
import '../source/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<DataState<UserEntity>> login(LoginRequestEntity params) async {
    try {

      final requestModel = LoginRequestModel.fromEntity(params);


      final httpResponse = await _apiService.login(requestModel);

      if (httpResponse.data != null) {
        final loginData = httpResponse.data!;


        await _localDataSource.saveTokens(
          accessToken: loginData.accessToken,
          refreshToken: loginData.refreshToken,
        );


        await _localDataSource.saveUser(loginData.user);


        return DataSuccess(data: loginData.user);
      } else {
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            error: httpResponse.message ?? 'Login data is empty',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> register(RegisterRequestEntity params) async {
    try {
      final requestModel = RegisterRequestModel.fromEntity(params);


      final httpResponse = await _apiService.register(requestModel);

      if (httpResponse.data != null) {


        await _localDataSource.saveUser(httpResponse.data!);

        return DataSuccess(data: httpResponse.data!);
      } else {
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: '/auth/register'),
            error: httpResponse.message ?? 'Register data is empty',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> getUserProfile() async {
    try {
      final httpResponse = await _apiService.getProfile();

      if (httpResponse.data != null) {

        await _localDataSource.saveUser(httpResponse.data!);
        return DataSuccess(data: httpResponse.data!);
      } else {
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: '/auth/me'),
            error: httpResponse.message ?? 'User Profile not found',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> updateProfile(
    UpdateProfileRequestEntity params,
  ) async {
    try {
      final requestModel = UpdateProfileRequestModel.fromEntity(params);
      final httpResponse = await _apiService.updateProfile(requestModel);

      if (httpResponse.data != null) {
        await _localDataSource.saveUser(httpResponse.data!);
        return DataSuccess(data: httpResponse.data!);
      } else {
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: '/auth/profile'),
            error: httpResponse.message ?? 'Update profile failed',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<void> logout() async {

    await _localDataSource.logout();
  }

  @override
  Future<bool> isLoggedIn() async {

    return _localDataSource.isLoggedIn();
  }

  @override
  Future<UserEntity?> getLastLocalUser() async {
    return _localDataSource
        .getLastUser();
  }

  @override
  Future<DataState<bool>> sendOtp({
    required String target,
    required String channel,
  }) async {
    try {
      final body = {'target': target, 'channel': channel};
      final httpResponse = await _apiService.sendOtp(body);

      if (httpResponse.status.toLowerCase() == 'success') {
        return DataSuccess(data: true);
      }

      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: '/auth/otp/send'),
          error: httpResponse.message ?? 'Failed to send OTP',
          type: DioExceptionType.badResponse,
        ),
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> verifyOtp({
    required String target,
    required String channel,
    required String code,
  }) async {
    try {
      final body = {'target': target, 'channel': channel, 'code': code};
      final httpResponse = await _apiService.verifyOtp(body);

      if (httpResponse.status.toLowerCase() == 'success') {

        final data = httpResponse.data;
        if (data != null && data['isUserUpdated'] != null) {
          final isUpdated = data['isUserUpdated'] == true;
          return DataSuccess(data: isUpdated);
        }
        return DataSuccess(data: true);
      }

      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: '/auth/otp/verify'),
          error: httpResponse.message ?? 'OTP verification failed',
          type: DioExceptionType.badResponse,
        ),
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
  @override
  Future<DataState<String>> refreshToken() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: '/refresh'),
            error: 'No refresh token found',
          ),
        );
      }

      final body = {'refreshToken': refreshToken};
      final httpResponse = await _apiService.refreshToken(body);

      final data = httpResponse.data;
      if (data != null && data['data'] != null) {
        final tokenData = data['data'] as Map<String, dynamic>;
        final newAccessToken = tokenData['accessToken'] as String?;
        final newRefreshToken = tokenData['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _localDataSource.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return DataSuccess(data: newAccessToken);
        }
      }

      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: '/refresh'),
          error: 'Refresh token failed: invalid response',
          type: DioExceptionType.badResponse,
        ),
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
