

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/bloc/auth/auth_state.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/auth/domain/usecase/get_local_user_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/is_logged_in_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/get_user_usecase.dart';
import 'package:rentverse/core/resources/data_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AppInitialState());
  Future<void> checkAuthStatus() async {
    try {
      final bool hasToken = await sl<IsLoggedInUsecase>().call();

      if (hasToken) {

        final local = await sl<GetLocalUserUseCase>().call();
        if (local != null) {
          emit(Authenticated(user: local));
        }


        try {
          final result = await sl<GetUserUseCase>().call();
          if (result is DataSuccess && result.data != null) {
            emit(Authenticated(user: result.data!));
          }
        } catch (_) {

        }
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(UnAuthenticated());
    }
  }
}
