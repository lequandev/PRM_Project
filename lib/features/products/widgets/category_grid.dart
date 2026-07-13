import 'package:flutter/material.dart';
import '../../../../util/colors.dart';

class CategoryGrid extends StatelessWidget {
  final bool isDarkMode;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryGrid({
    super.key,
    required this.isDarkMode,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, String>> categories = [
    {'id': 'coffee', 'name': 'Coffee Drinks', 'icon': '☕', 'filter': 'coffee'},
    {'id': 'detox', 'name': 'Detox', 'icon': '🍋', 'filter': 'tea'},
    {'id': 'food', 'name': 'Food', 'icon': '🥪', 'filter': 'dessert'},
    {'id': 'bakery', 'name': 'Bakery', 'icon': '🥐', 'filter': 'cake'},
    {'id': 'roasted', 'name': 'Roasted', 'icon': '🫘', 'filter': 'beans'},
    {'id': 'instant', 'name': 'Instant', 'icon': '🥤', 'filter': 'coffee'},
    {'id': 'beans', 'name': 'Coffee Beans', 'icon': '📦', 'filter': 'beans'},
    {'id': 'gifts', 'name': 'Gifts', 'icon': '🎁', 'filter': 'gift'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? LuxeColors.cardDark : LuxeColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : const Color(0x0DE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KHÁM PHÁ DANH MỤC',
                style: TextStyle(
                  color: LuxeColors.goldPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '8 categories',
                style: TextStyle(color: LuxeColors.textHint, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final bool isActive = selectedCategory == cat['filter'];
              return GestureDetector(
                onTap: () => onCategorySelected(cat['filter']!),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? LuxeColors.goldPrimary
                            : (isDarkMode
                                  ? Colors.amber.withOpacity(0.1)
                                  : Colors.grey[300]),
                      ),
                      child: Center(
                        child: Text(
                          cat['icon']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['name']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isActive ? LuxeColors.goldPrimary : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
