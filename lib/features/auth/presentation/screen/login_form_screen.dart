

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../common/colors/custom_color.dart';
import '../cubit/auth/auth_page_cubit.dart';
import '../../../../common/bloc/auth/auth_cubit.dart';
import '../cubit/login/login_cubit.dart';
import '../cubit/login/login_state.dart';
import '../widget/custom_button.dart';

class LoginFormScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            'https://res.cloudinary.com/dy4hqxkv1/image/upload/v1766691043/Container_tubl0q.png',
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 120,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                "Welcome Back!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to continue your journey",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),


              Text(
                "Email Address",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF225555),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "yourname@example.com",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(LucideIcons.mail,
                    color: Color(0xFF225555),
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: appPrimaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "We'll use this email for your account verification",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),


              Text(
                "Password",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF225555),
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !state.isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Enter your secure password",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(LucideIcons.lock,
                            color: Color(0xFF225555),
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.isPasswordVisible
                                  ? LucideIcons.eye
                                  : LucideIcons.eyeOff,
                              color: const Color(0xFF225555),
                              size: 20,
                            ),
                            onPressed: () {
                              context
                                  .read<LoginCubit>()
                                  .togglePasswordVisibility();
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: appPrimaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Your password must be at least 6 characters long",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),


              BlocConsumer<LoginCubit, LoginState>(
                listener: (context, state) {
                  if (state.status == LoginStatus.success) {

                    context.read<AuthCubit>().checkAuthStatus();
                  } else if (state.status == LoginStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage ?? "Error")),
                    );
                  }
                },
                builder: (context, state) {
                  return CustomButton(
                    text: "Sign In",
                    isLoading: state.status == LoginStatus.loading,
                    onTap: () {
                      context.read<LoginCubit>().submitLogin(
                            _emailController.text,
                            _passwordController.text,
                          );
                    },
                  );
                },
              ),

              const SizedBox(height: 16),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New to Rentverse? ",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {

                      context.read<AuthPageCubit>().showRegister();
                    },
                    child: Text(
                      "Create an account",
                      style: GoogleFonts.poppins(
                        color: appSecondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
