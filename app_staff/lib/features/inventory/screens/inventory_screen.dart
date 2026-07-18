import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../providers/staff_inventory_provider.dart';
import '../../auth/providers/staff_auth_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'low', 'out_of_stock'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAdjustStockDialog(BuildContext context, IngredientModel ingredient) {
    final authProvider = context.read<StaffAuthProvider>();
    final inventoryProvider = context.read<StaffInventoryProvider>();
    final controller = TextEditingController(text: ingredient.currentStock.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Điều chỉnh kho: ${ingredient.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đơn vị tính: ${ingredient.unit}'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập số lượng';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed < 0) return 'Số lượng phải lớn hơn hoặc bằng 0';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Số lượng tồn kho mới',
                  hintText: 'Nhập số lượng...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newStock = double.parse(controller.text.trim());
              Navigator.pop(ctx);
              
              final success = await inventoryProvider.updateStockLevel(
                ingredientId: ingredient.id,
                newStock: newStock,
                updatedBy: authProvider.currentUser?.uid ?? 'unknown_staff',
              );
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã cập nhật tồn kho cho ${ingredient.name}')),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<StaffInventoryProvider>();
    final authProvider = context.read<StaffAuthProvider>();

    // Lọc nguyên liệu theo từ khóa tìm kiếm và tab lọc
    final filteredIngredients = inventoryProvider.ingredients.where((item) {
      final nameMatches = item.name.withoutDiacritics.toLowerCase()
          .contains(_searchQuery.withoutDiacritics.toLowerCase());
      
      if (!nameMatches) return false;

      switch (_selectedFilter) {
        case 'low':
          return item.isLow;
        case 'out_of_stock':
          return item.isOutOfStock;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QUẢN LÝ KHO NGUYÊN LIỆU'),
      ),
      body: inventoryProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
              ),
            )
          : inventoryProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: AppSpacing.md),
                      Text(inventoryProvider.errorMessage!, style: AppTypography.h4),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search & Filter Header
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm nguyên liệu...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              _buildFilterButton('Tất cả', 'all', inventoryProvider.ingredients.length),
                              const SizedBox(width: AppSpacing.sm),
                              _buildFilterButton(
                                'Sắp hết',
                                'low',
                                inventoryProvider.ingredients.where((i) => i.isLow).length,
                                activeColor: AppColors.warning,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _buildFilterButton(
                                'Hết hàng',
                                'out_of_stock',
                                inventoryProvider.ingredients.where((i) => i.isOutOfStock).length,
                                activeColor: AppColors.error,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Inventory Items List
                    Expanded(
                      child: filteredIngredients.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textHint.withOpacity(0.5)),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Không tìm thấy nguyên liệu nào',
                                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              itemCount: filteredIngredients.length,
                              itemBuilder: (context, index) {
                                final item = filteredIngredients[index];
                                return _buildIngredientCard(context, item, authProvider, inventoryProvider);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterButton(String label, String value, int count, {Color activeColor = AppColors.goldPrimary}) {
    final isSelected = _selectedFilter == value;

    return Expanded(
      child: FilterChip(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : activeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? activeColor : activeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        selected: isSelected,
        selectedColor: activeColor,
        checkmarkColor: AppColors.white,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildIngredientCard(
    BuildContext context,
    IngredientModel item,
    StaffAuthProvider authProvider,
    StaffInventoryProvider inventoryProvider,
  ) {
    Color statusColor;
    String statusLabel;

    if (item.isOutOfStock) {
      statusColor = AppColors.error;
      statusLabel = 'HẾT HÀNG';
    } else if (item.isLow) {
      statusColor = AppColors.warning;
      statusLabel = 'SẮP HẾT';
    } else {
      statusColor = AppColors.success;
      statusLabel = 'CÒN HÀNG';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Status Indicator Circle
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Tồn kho: ${item.currentStock} ${item.unit}',
                        style: TextStyle(
                          color: item.isOutOfStock ? AppColors.error : AppColors.textPrimary,
                          fontWeight: item.isOutOfStock ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(Tối thiểu: ${item.minStock} ${item.unit})',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge & Controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTypography.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    // Adjust Button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.goldPrimary),
                      onPressed: () => _showAdjustStockDialog(context, item),
                      tooltip: 'Chỉnh sửa số lượng',
                    ),
                    // Out of stock switch button
                    if (!item.isOutOfStock)
                      IconButton(
                        icon: const Icon(Icons.block, size: 20, color: AppColors.error),
                        onPressed: () async {
                          final success = await inventoryProvider.markOutOfStock(
                            ingredientId: item.id,
                            updatedBy: authProvider.currentUser?.uid ?? 'unknown_staff',
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã đánh dấu hết hàng: ${item.name}')),
                            );
                          }
                        },
                        tooltip: 'Đánh dấu hết hàng',
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
