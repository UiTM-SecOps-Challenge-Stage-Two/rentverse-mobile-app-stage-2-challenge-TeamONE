

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../common/colors/custom_color.dart';
import '../widget/custom_button.dart';
import '../cubit/choose_role/cubit.dart';
import '../cubit/choose_role/state.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChooseRoleCubit(),
      child: Scaffold(
        backgroundColor: appBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.of(context).maybePop(),
          ),

          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Select your role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              _roleCards(),
              const Spacer(),
              _registerButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCards() {
    return BlocBuilder<ChooseRoleCubit, ChooseRoleState>(
      builder: (context, state) {
        return Column(
          children: [
            _roleCard(
              title: 'Tenant',
              subtitle:
                  'Tenants rent properties and build trust scores through on-time payments and property care',
              selected: state.selected == UserRole.tenant,
              onTap: () => context.read<ChooseRoleCubit>().selectTenant(),
            ),
            const SizedBox(height: 12),
            _roleCard(
              title: 'Owner Property',
              subtitle:
                  'Owners provide properties and are rated based on listing accuracy, maintenance service, and communication',
              selected: state.selected == UserRole.owner,
              onTap: () => context.read<ChooseRoleCubit>().selectOwner(),
            ),
          ],
        );
      },
    );
  }

  Widget _roleCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: selected ? null : Border.all(color: Colors.grey.shade300),

          gradient: selected ? customLinearGradient : null,
        ),

        padding: EdgeInsets.all(selected ? 2 : 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),

          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return BlocBuilder<ChooseRoleCubit, ChooseRoleState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Register',
          isLoading: state.isSubmitting,
          onTap: state.selected == null
              ? () {}
              : () => context.read<ChooseRoleCubit>().submit((role) {
                    Navigator.pop(context, role);
                  }),
        );
      },
    );
  }
}
