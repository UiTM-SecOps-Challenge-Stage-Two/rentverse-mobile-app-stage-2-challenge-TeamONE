import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String displayName;
  final Color? backgroundColor;
  final double height;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    required this.displayName,
    this.backgroundColor,
    this.height = 60,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? Color(0xFFEEEEEE);

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      elevation: 0,
      toolbarHeight: height,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: effectiveBackgroundColor,
        statusBarIconBrightness:
            effectiveBackgroundColor.computeLuminance() > 0.5
                ? Brightness.dark
                : Brightness.light,
        statusBarBrightness: effectiveBackgroundColor.computeLuminance() > 0.5
            ? Brightness.light
            : Brightness.dark,
      ),
      leadingWidth: 68,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFEEEEEE),
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ),
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selamat Datang',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
          child: InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(LucideIcons.bell,
                  color: Colors.black87,
                  size: 24,
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
