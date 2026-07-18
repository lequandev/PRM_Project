import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedCategoryId;
  final Function(String) onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              labelPadding: EdgeInsets.zero,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category.id);
                }
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.goldPrimary.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.goldPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        },
      ),
    );
  }
}
