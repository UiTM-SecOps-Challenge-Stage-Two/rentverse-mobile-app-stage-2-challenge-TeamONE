

import 'dart:developer' as developer;

import 'package:rentverse/features/auth/data/models/request/login_request_model.dart';
import 'package:rentverse/features/auth/data/models/request/register_request_model.dart';
import 'package:rentverse/features/auth/data/models/request/update_profile_request_model.dart';
import 'package:rentverse/features/auth/data/models/response/login_response_model.dart';
import 'package:rentverse/features/auth/data/models/response/user_model.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response/base_response_model.dart';


abstract class AuthApiService {
  Future<BaseResponseModel<LoginResponseModel>> login(LoginRequestModel body);
  Future<BaseResponseModel<UserModel>> register(RegisterRequestModel body);
  Future<BaseResponseModel<UserModel>> getProfile();
  Future<BaseResponseModel<UserModel>> updateProfile(
    UpdateProfileRequestModel body,
  );
  Future<BaseResponseModel<Map<String, dynamic>>> sendOtp(
    Map<String, dynamic> body,
  );

  Future<BaseResponseModel<Map<String, dynamic>>> verifyOtp(
    Map<String, dynamic> body,
  );

  Future<BaseResponseModel<Map<String, dynamic>>> refreshToken(
    Map<String, dynamic> body,
  );
}


class AuthApiServiceImpl implements AuthApiService {
  final DioClient _dioClient;

  AuthApiServiceImpl(this._dioClient);

  @override
  Future<BaseResponseModel<LoginResponseModel>> login(
    LoginRequestModel body,
  ) async {
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: body.toJson(),
      );

      return BaseResponseModel.fromJson(
        response.data,
        (json) => LoginResponseModel.fromJson(
          json as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseResponseModel<UserModel>> register(
    RegisterRequestModel body,
  ) async {
    try {
      final response = await _dioClient.post(
        '/auth/register',
        data: body.toJson(),
      );

      return BaseResponseModel.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseResponseModel<UserModel>> getProfile() async {
    try {
      final response = await _dioClient.get('/auth/me');


      developer.log(
        'GET /auth/me raw response: ${response.data}',
        name: 'AuthApiService',
      );

      return BaseResponseModel.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseResponseModel<UserModel>> updateProfile(
    UpdateProfileRequestModel body,
  ) async {
    try {
      final response = await _dioClient.put(
        '/auth/profile',
        data: body.toJson(),
      );
      return BaseResponseModel.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> sendOtp(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dioClient.post('/auth/otp/send', data: body);

      return BaseResponseModel.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> verifyOtp(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dioClient.post('/auth/otp/verify', data: body);

      return BaseResponseModel.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> refreshToken(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dioClient.post('/auth/refresh', data: body);

      return BaseResponseModel.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
