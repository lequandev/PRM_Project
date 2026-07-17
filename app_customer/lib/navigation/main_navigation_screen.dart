import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../features/cart/providers/cart_provider.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Premium Design: We use a custom styled BottomNavigationBar
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: AppColors.transparent,
              type: BottomNavigationBarType.fixed,
              currentIndex: navigationShell.currentIndex,
              selectedItemColor: AppColors.goldPrimary,
              unselectedItemColor: AppColors.textHint,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              onTap: (index) => _onTap(context, index),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.coffee_outlined),
                  activeIcon: Icon(Icons.coffee_rounded),
                  label: 'Menu',
                ),
                BottomNavigationBarItem(
                  icon: Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      final int quantity = cart.totalQuantity;
                      if (quantity == 0) {
                        return const Icon(Icons.shopping_bag_outlined);
                      }
                      return _AnimatedCartIcon(
                        itemCount: quantity,
                        child: Badge(
                          label: Text(quantity.toString()),
                          backgroundColor: AppColors.error,
                          child: const Icon(Icons.shopping_bag_outlined),
                        ),
                      );
                    },
                  ),
                  activeIcon: Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      final int quantity = cart.totalQuantity;
                      if (quantity == 0) {
                        return const Icon(Icons.shopping_bag_rounded);
                      }
                      return _AnimatedCartIcon(
                        itemCount: quantity,
                        child: Badge(
                          label: Text(quantity.toString()),
                          backgroundColor: AppColors.error,
                          child: const Icon(Icons.shopping_bag_rounded),
                        ),
                      );
                    },
                  ),
                  label: 'Giỏ hàng',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Đơn hàng',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Tài khoản',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCartIcon extends StatefulWidget {
  final Widget child;
  final int itemCount;

  const _AnimatedCartIcon({required this.child, required this.itemCount});

  @override
  State<_AnimatedCartIcon> createState() => _AnimatedCartIconState();
}

class _AnimatedCartIconState extends State<_AnimatedCartIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Hiệu ứng "pop" nhẹ
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_AnimatedCartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kích hoạt animation khi số lượng tăng lên
    if (widget.itemCount > oldWidget.itemCount) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
