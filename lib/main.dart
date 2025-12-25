import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/bloc/auth/auth_cubit.dart';
import 'package:rentverse/common/bloc/auth/auth_state.dart';
import 'package:rentverse/common/bloc/navigation/navigation_cubit.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:rentverse/core/services/notification_service.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/auth/domain/entity/user_entity.dart';
import 'package:rentverse/features/auth/presentation/pages/auth_pages.dart';
import 'package:rentverse/features/auth/presentation/pages/profile_pages.dart';
import 'package:rentverse/role/lanlord/presentation/pages/booking.dart';
import 'package:rentverse/role/lanlord/presentation/pages/chat.dart';
import 'package:rentverse/role/lanlord/presentation/pages/dashboard.dart';
import 'package:rentverse/role/lanlord/presentation/pages/property.dart';
import 'package:rentverse/role/tenant/presentation/pages/nav/chat.dart';
import 'package:rentverse/role/tenant/presentation/pages/nav/home.dart';
import 'package:rentverse/role/tenant/presentation/pages/property/property.dart';
import 'package:rentverse/role/tenant/presentation/pages/nav/rent.dart';
import 'package:rentverse/common/screen/navigation_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeFirebase();
  await setupServiceLocator();
  final notificationService = sl<NotificationService>();
  await notificationService.initLocalNotifications();
  await notificationService.configureForegroundPresentation();
  notificationService.listenForegroundMessages();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (context) => sl<NavigationCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: appBackgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              final nav = _buildNavigationConfig(state.user);
              return NavigationContainer(pages: nav.pages, items: nav.items);
            } else if (state is UnAuthenticated) {
              return const AuthPages();
            } else {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}

class _NavigationConfig {
  final List<Widget> pages;
  final List<BottomNavigationBarItem> items;

  const _NavigationConfig({required this.pages, required this.items});
}

_NavigationConfig _buildNavigationConfig(UserEntity user) {
  if (user.isLandlord) {
    return _NavigationConfig(
      pages: const [
        LandlordDashboardPage(),
        LandlordPropertyPage(),
        LandlordBookingPage(),
        LandlordChatPage(),
        ProfilePage(),
      ],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.layoutDashboard, color: Colors.grey),
          activeIcon: GradientIcon(icon: LucideIcons.layoutDashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.building, color: Colors.grey),
          activeIcon: GradientIcon(icon: LucideIcons.building),
          label: 'Property',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.receipt, color: Colors.grey),
          activeIcon: GradientIcon(icon: LucideIcons.receipt),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.messageCircle, color: Colors.grey),
          activeIcon: GradientIcon(icon: LucideIcons.messageCircle),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.user, color: Colors.grey),
          activeIcon: GradientIcon(icon: LucideIcons.user),
          label: 'Profile',
        ),
      ],
    );
  }

  return _NavigationConfig(
    pages: const [
      TenantHomePage(),
      TenantPropertyPage(),
      TenantRentPage(),
      TenantChatPage(),
      ProfilePage(),
    ],
    items: const [
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.home, color: Colors.grey),
        activeIcon: GradientIcon(icon: LucideIcons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.building, color: Colors.grey),
        activeIcon: GradientIcon(icon: LucideIcons.building),
        label: 'Property',
      ),
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.receipt, color: Colors.grey),
        activeIcon: GradientIcon(icon: LucideIcons.receipt),
        label: 'Rent',
      ),
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.messageCircle, color: Colors.grey),
        activeIcon: GradientIcon(icon: LucideIcons.messageCircle),
        label: 'Chat',
      ),
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.user, color: Colors.grey),
        activeIcon: GradientIcon(icon: LucideIcons.user),
        label: 'Profile',
      ),
    ],
  );
}
