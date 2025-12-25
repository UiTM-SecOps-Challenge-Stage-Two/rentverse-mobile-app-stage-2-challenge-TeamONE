import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart';
import '../cubit/auth/auth_page_cubit.dart';
import '../cubit/auth/auth_page_state.dart';
import '../cubit/login/login_cubit.dart';
import '../cubit/register/register_cubit.dart';
import '../screen/login_form_screen.dart';
import '../screen/register_form_screen.dart';

class AuthPages extends StatelessWidget {
  const AuthPages({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        BlocProvider<AuthPageCubit>(create: (context) => AuthPageCubit()),


        BlocProvider<LoginCubit>(create: (context) => LoginCubit(sl(), sl())),


        BlocProvider<RegisterCubit>(create: (context) => RegisterCubit(sl())),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<AuthPageCubit, AuthPageType>(
            builder: (context, state) {
              if (state == AuthPageType.login) {
                return LoginFormScreen();
              } else {
                return RegisterFormScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
