

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/core/utils/error_utils.dart';
import 'package:rentverse/features/auth/domain/entity/register_request_enity.dart';
import 'package:rentverse/features/auth/domain/usecase/register_usecase.dart';

import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUsecase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(const RegisterState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    emit(
      state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible),
    );
  }


  void updateRole(String role) {
    emit(state.copyWith(role: role));
  }


  void validateFields({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    String? nameError;
    String? emailError;
    String? phoneError;
    String? passwordError;
    String? confirmError;

    if (name.trim().isEmpty) {
      nameError = "Full Name cannot be empty";
    }
    if (email.trim().isEmpty) {
      emailError = "Email cannot be empty";
    }
    if (phone.trim().isEmpty) {
      phoneError = "Phone Number cannot be empty";
    }
    if (password.isEmpty) {
      passwordError = "Password cannot be empty";
    }
    if (confirmPassword.isEmpty) {
      confirmError = "Confirm Password cannot be empty";
    } else if (password != confirmPassword) {
      confirmError = "Passwords do not match";
    }

    emit(
      state.copyWith(
        nameError: nameError,
        emailError: emailError,
        phoneError: phoneError,
        passwordError: passwordError,
        confirmPasswordError: confirmError,
      ),
    );
  }

  Future<void> submitRegister({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
  }) async {

    validateFields(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (state.nameError != null ||
        state.emailError != null ||
        state.phoneError != null ||
        state.passwordError != null ||
        state.confirmPasswordError != null) {
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    final result = await _registerUseCase(
      param: RegisterRequestEntity(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: state.role,
      ),
    );

    if (result is DataSuccess) {
      emit(state.copyWith(status: RegisterStatus.success));
    } else if (result is DataFailed) {
      final errorMsg = resolveApiErrorMessage(
        result.error,
        fallback: 'Registration Failed',
      );

      emit(
        state.copyWith(status: RegisterStatus.failure, errorMessage: errorMsg),
      );
    }
  }
}
