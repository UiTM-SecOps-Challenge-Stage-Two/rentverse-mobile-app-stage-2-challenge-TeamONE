import 'package:flutter/material.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:rentverse/common/screen/navigation_container.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/auth/presentation/pages/profile_pages.dart';
import 'package:rentverse/role/tenant/presentation/pages/nav/chat.dart';
import 'package:rentverse/role/tenant/presentation/pages/nav/home.dart';
import 'package:rentverse/role/tenant/presentation/pages/property/property.dart';
import 'package:rentverse/role/tenant/presentation/pages/nav/rent.dart';
import 'package:lucide_icons/lucide_icons.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyTestApp());
}


class MyTestApp extends StatelessWidget {
  const MyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: appBackgroundColor),
      home: const NavigationContainer(
        pages: [
          TenantHomePage(),
          TenantPropertyPage(),
          TenantRentPage(),
          TenantChatPage(),
          ProfilePage(),
        ],
        items: [
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
            icon: Icon(LucideIcons.messageSquare, color: Colors.grey),
            activeIcon: GradientIcon(icon: LucideIcons.messageSquare),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user, color: Colors.grey),
            activeIcon: GradientIcon(icon: LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
