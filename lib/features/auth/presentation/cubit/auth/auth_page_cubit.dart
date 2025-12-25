

import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_page_state.dart';

class AuthPageCubit extends Cubit<AuthPageType> {
  AuthPageCubit() : super(AuthPageType.login);

  void showLogin() => emit(AuthPageType.login);
  void showRegister() => emit(AuthPageType.register);
}
