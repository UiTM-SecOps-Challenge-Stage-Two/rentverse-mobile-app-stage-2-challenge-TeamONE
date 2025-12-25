import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/auth/domain/repository/auth_repository.dart';
import '../constant/api_urls.dart';

class DioInterceptor extends Interceptor {
  final Logger _logger;
  final SharedPreferences _sharedPreferences;
  final Dio _dio;
  Future<String?>? _refreshFuture;

  DioInterceptor(this._logger, this._sharedPreferences, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {

    _logger.i('--> ${options.method.toUpperCase()} ${options.uri}');
    _logger.t('Headers: ${options.headers}');
    _logger.t('Body: ${options.data}');


    final path = options.path;
    if (path.contains('/auth/refresh') ||
        path.contains('/auth/login') ||
        path.contains('/auth/register')) {
      return super.onRequest(options, handler);
    }


    final token = _sharedPreferences.getString(ApiConstants.tokenKey);


    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }


    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {

    _logger.d('<-- ${response.statusCode} ${response.requestOptions.uri}');
    _logger.t('Data: ${response.data}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {

    _logger.e('<-- ${err.response?.statusCode} ${err.requestOptions.uri}');
    _logger.e('Message: ${err.message}');
    _logger.e('Error Data: ${err.response?.data}');
    if (_shouldAttemptRefresh(err)) {
      await _handleTokenRefresh(err, handler);
    } else {
      super.onError(err, handler);
    }
  }

  bool _shouldAttemptRefresh(DioException err) {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final hasRetried = err.requestOptions.extra['__retry'] == true;

    final isRefreshEndpoint = path.contains('/auth/refresh');
    final isLoginEndpoint = path.contains('/auth/login');

    return statusCode == 401 &&
        !isRefreshEndpoint &&
        !isLoginEndpoint &&
        !hasRetried;
  }

  Future<void> _handleTokenRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final newToken = await _refreshToken();

      if (newToken == null || newToken.isEmpty) {

        _logger.w('Token refresh failed, propagating 401');
        return handler.next(err);
      }


      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      opts.extra['__retry'] = true;


      final response = await _dio.fetch(opts);
      handler.resolve(response);
    } catch (e) {

      handler.next(err);
    }
  }

  Future<String?> _refreshToken() {

    final existing = _refreshFuture;
    if (existing != null) return existing;

    final future = (() async {
      try {


        final authRepo = sl<AuthRepository>();
        final result = await authRepo.refreshToken();

        if (result is DataSuccess && result.data != null) {
          _logger.i('Token refreshed successfully via AuthRepository');
          return result.data;
        } else {
          _logger.e('AuthRepository.refreshToken failed: ${result.error?.message}');
          return null;
        }
      } catch (e) {
        _logger.e('Unexpected error during refresh: $e');
        return null;
      } finally {
        _refreshFuture = null;
      }
    })();

    _refreshFuture = future;
    return future;
  }
}
