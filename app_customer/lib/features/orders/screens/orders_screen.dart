import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Đơn hàng', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Lịch sử đơn hàng',
          style: TextStyle(color: AppColors.textHint),
        ),
      ),
    );
  }
}
