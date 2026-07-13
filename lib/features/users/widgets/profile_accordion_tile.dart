import 'package:flutter/material.dart';

class ProfileAccordionTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final bool isOpen;
  final VoidCallback onTap;
  final Widget child;
  final bool isDarkMode;

  const ProfileAccordionTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.isOpen,
    required this.onTap,
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: Icon(
              leadingIcon,
              color: const Color(0xFFD4AF37),
              size: 18,
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              isOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 18,
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
