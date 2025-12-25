import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../common/colors/custom_color.dart';
import '../cubit/auth/auth_page_cubit.dart';
import '../cubit/register/register_cubit.dart';
import '../cubit/register/register_state.dart';
import '../widget/custom_button.dart';
import 'choose_role_screen.dart';
import '../cubit/choose_role/state.dart';

class RegisterFormScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  RegisterFormScreen({super.key});

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
                "Create Account",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join Rentverse and start your journey",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),


              Text(
                "Full Name",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF225555),
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<RegisterCubit, RegisterState>(
                buildWhen: (p, c) => p.nameError != c.nameError,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: "John Doe",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.user,
                            color: Color(0xFF225555),
                            size: 20,
                          ),
                          errorText: state.nameError,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      if (state.nameError == null) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Your full name as it appears on your ID",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),


              Text(
                "Email Address",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF225555),
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<RegisterCubit, RegisterState>(
                buildWhen: (p, c) => p.emailError != c.emailError,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "yourname@example.com",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.mail,
                            color: Color(0xFF225555),
                            size: 20,
                          ),
                          errorText: state.emailError,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      if (state.emailError == null) ...[
                        const SizedBox(height: 6),
                        Text(
                          "We'll send verification link to this email",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),


              Text(
                "Phone Number",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF225555),
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<RegisterCubit, RegisterState>(
                buildWhen: (p, c) => p.phoneError != c.phoneError,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "0812-3456-7890",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.phone,
                            color: Color(0xFF225555),
                            size: 20,
                          ),
                          errorText: state.phoneError,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      if (state.phoneError == null) ...[
                        const SizedBox(height: 6),
                        Text(
                          "We'll use this for account recovery and notifications",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  );
                },
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
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !state.isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Create a strong password",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.lock,
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
                            onPressed: () => context
                                .read<RegisterCubit>()
                                .togglePasswordVisibility(),
                          ),
                          errorText: state.passwordError,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      if (state.passwordError == null) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Must be at least 6 characters long",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),


              Text(
                "Confirm Password",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF225555),
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !state.isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Re-enter your password",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.lock,
                            color: Color(0xFF225555),
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.isConfirmPasswordVisible
                                  ? LucideIcons.eye
                                  : LucideIcons.eyeOff,
                              color: const Color(0xFF225555),
                              size: 20,
                            ),
                            onPressed: () => context
                                .read<RegisterCubit>()
                                .toggleConfirmPasswordVisibility(),
                          ),
                          errorText: state.confirmPasswordError,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      if (state.confirmPasswordError == null) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Both passwords must match",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),


              BlocConsumer<RegisterCubit, RegisterState>(
                listener: (context, state) {
                  if (state.status == RegisterStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Registration Successful! Please Login."),
                      ),
                    );
                    context.read<AuthPageCubit>().showLogin();
                  } else if (state.status == RegisterStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage ?? "Error")),
                    );
                  }
                },
                builder: (context, state) {
                  return CustomButton(
                    text: "Next",
                    isLoading: state.status == RegisterStatus.loading,
                    onTap: () async {
                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      final phone = _phoneController.text.trim();
                      final password = _passwordController.text;
                      final confirmPassword = _confirmPasswordController.text;

                      context.read<RegisterCubit>().validateFields(
                            name: name,
                            email: email,
                            phone: phone,
                            password: password,
                            confirmPassword: confirmPassword,
                          );

                      final s = context.read<RegisterCubit>().state;
                      if (s.nameError != null ||
                          s.emailError != null ||
                          s.phoneError != null ||
                          s.passwordError != null ||
                          s.confirmPasswordError != null) {
                        return;
                      }

                      final result = await Navigator.push<UserRole?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChooseRoleScreen(),
                        ),
                      );

                      if (result == null) return;
                      final roleString =
                          result == UserRole.tenant ? 'TENANT' : 'LANDLORD';

                      context.read<RegisterCubit>().updateRole(roleString);
                      await context.read<RegisterCubit>().submitRegister(
                            name: name,
                            email: email,
                            phone: phone,
                            password: password,
                            confirmPassword: confirmPassword,
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
                    "Already have an account? ",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<AuthPageCubit>().showLogin(),
                    child: Text(
                      "Sign in",
                      style: GoogleFonts.poppins(
                        color: appSecondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
