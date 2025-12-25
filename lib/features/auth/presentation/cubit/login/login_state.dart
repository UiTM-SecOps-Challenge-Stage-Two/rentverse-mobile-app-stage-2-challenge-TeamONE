

import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final bool isPasswordVisible;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.isPasswordVisible = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isPasswordVisible,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isPasswordVisible, status, errorMessage];
}
