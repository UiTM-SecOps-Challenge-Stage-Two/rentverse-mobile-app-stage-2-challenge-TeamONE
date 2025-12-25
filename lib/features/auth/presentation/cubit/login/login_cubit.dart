import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/core/services/notification_service.dart';
import 'package:rentverse/core/utils/error_utils.dart';
import 'package:rentverse/features/auth/domain/entity/login_request_entity.dart';
import 'package:rentverse/features/auth/domain/usecase/login_usecase.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {

  final LoginUseCase _loginUseCase;
  final NotificationService _notificationService;

  LoginCubit(this._loginUseCase, this._notificationService)
    : super(const LoginState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> submitLogin(String email, String password) async {

    emit(state.copyWith(status: LoginStatus.loading));


    final result = await _loginUseCase(
      param: LoginRequestEntity(email: email, password: password),
    );


    if (result is DataSuccess) {

      try {
        await _notificationService.requestPermission();
        await _notificationService.configureForegroundPresentation();
        await _notificationService.registerDevice();
        _notificationService.listenTokenRefresh();
      } catch (_) {}

      emit(state.copyWith(status: LoginStatus.success));
    } else if (result is DataFailed) {

      final apiMessage = resolveApiErrorMessage(result.error, fallback: '');
      final errorMsg = apiMessage;

      emit(state.copyWith(status: LoginStatus.failure, errorMessage: errorMsg));
    }
  }
}
