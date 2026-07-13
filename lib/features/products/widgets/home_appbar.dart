import 'package:flutter/material.dart';
import '../../../../util/colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final int unreadNotifications;
  final VoidCallback onMenuTap;

  const HomeAppBar({
    super.key,
    required this.isDarkMode,
    required this.unreadNotifications,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDarkMode
          ? const Color(0xFF171717)
          : const Color(0xFFFFF8EE),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: LuxeColors.goldPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DANH MỤC',
                style: TextStyle(
                  color: LuxeColors.goldPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Boutique Coffee',
                style: TextStyle(color: Colors.grey, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.favorite,
            color: LuxeColors.errorRed,
            size: 20,
          ),
          onPressed: () {},
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {},
            ),
            if (unreadNotifications > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: LuxeColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.menu,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: onMenuTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
