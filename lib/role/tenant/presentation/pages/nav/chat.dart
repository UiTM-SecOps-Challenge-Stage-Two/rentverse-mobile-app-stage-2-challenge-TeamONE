import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/bloc/auth/auth_cubit.dart';
import 'package:rentverse/common/bloc/auth/auth_state.dart';
import 'package:rentverse/features/chat/presentation/pages/chat_list_page.dart';

class TenantChatPage extends StatelessWidget {
  const TenantChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          final user = authState.user;

          if (user.isTenant) {
            final kyc = user.tenantProfile?.kycStatus ?? '';
            if (kyc.toUpperCase() != 'VERIFIED') {
              return const Center(child: Text('Menunggu terverifikasi'));
            }
          }
        }
        return const ChatListPage(isLandlord: false);
      },
    );
  }
}
