import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:intl/intl.dart';
import '../providers/admin_product_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProductProvider>();
    final fmt =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Sản phẩm',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownAccent,
                      ),
                    ),
                    Text(
                      'Tạo, cập nhật và quản lý menu cà phê',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  key: const Key('btn_add_product'),
                  onPressed: () => context.go('/products/new'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Thêm sản phẩm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brownAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Filters & Search ───────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Search bar (Fixed) + Refresh button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: provider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textHint, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.brownAccent, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Tải lại',
                      onPressed: provider.loadProducts,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Filter chips & dropdown wrapping dynamically
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _FilterChip(
                      label: 'Đang bán',
                      isSelected: provider.filterStatus == 'active',
                      onTap: () => provider.setFilterStatus('active'),
                    ),
                    _FilterChip(
                      label: 'Đã archive',
                      isSelected: provider.filterStatus == 'archived',
                      onTap: () => provider.setFilterStatus('archived'),
                    ),
                    _FilterChip(
                      label: 'Tất cả',
                      isSelected: provider.filterStatus == 'all',
                      onTap: () => provider.setFilterStatus('all'),
                    ),
                    if (provider.categories.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.filterCategoryId.isEmpty
                                ? ''
                                : provider.filterCategoryId,
                            hint: const Text('Danh mục'),
                            isDense: true,
                            items: [
                              const DropdownMenuItem(
                                  value: '', child: Text('Tất cả danh mục')),
                              ...provider.categories.map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  )),
                            ],
                            onChanged: (v) =>
                                provider.setFilterCategory(v ?? ''),
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Error banner ──────────────────────────────────────────────
            if (provider.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(provider.errorMessage!,
                          style: const TextStyle(color: AppColors.error)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.error, size: 18),
                      onPressed: provider.clearError,
                    ),
                  ],
                ),
              ),

            // ── Product list (responsive) ─────────────────────────────────
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.products.isEmpty
                      ? _EmptyState(
                          onAdd: () => context.go('/products/new'),
                        )
                      : LayoutBuilder(builder: (ctx, bc) {
                          final isMobile = bc.maxWidth < 700;

                          // ── Mobile: card list ───────────────────────
                          if (isMobile) {
                            return ListView.separated(
                              itemCount: provider.products.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, idx) {
                                final product = provider.products[idx];
                                final catName = provider.categories
                                    .firstWhere(
                                      (c) => c.id == product.categoryId,
                                      orElse: () => const CategoryModel(
                                        id: '',
                                        name: '—',
                                        displayOrder: 0,
                                        isActive: true,
                                      ),
                                    )
                                    .name;
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Thumbnail
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: AppColors.beigeWarm,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: product.imageUrl != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  product.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(Icons.coffee,
                                                          color: AppColors
                                                              .brownAccent),
                                                ),
                                              )
                                            : const Icon(Icons.coffee,
                                                color: AppColors.brownAccent),
                                      ),
                                      const SizedBox(width: 12),
                                      // Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    catName,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textSecondary,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  fmt.format(product.basePrice),
                                                  style: const TextStyle(
                                                    color: AppColors.brownAccent,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (product.tags.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Wrap(
                                                  spacing: 4,
                                                  children: product.tags
                                                      .map(
                                                          (t) => _TagChip(tag: t))
                                                      .toList(),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Actions
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Switch(
                                            value: product.isAvailable &&
                                                !product.isArchived,
                                            onChanged: product.isArchived
                                                ? null
                                                : (v) => context
                                                    .read<AdminProductProvider>()
                                                    .toggleAvailability(
                                                        product.id, v),
                                            activeThumbColor: AppColors.success,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.edit_rounded,
                                                    size: 18,
                                                    color:
                                                        AppColors.brownAccent),
                                                tooltip: 'Sửa',
                                                onPressed: () => context.go(
                                                    '/products/${product.id}/edit'),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                              const SizedBox(width: 4),
                                              if (!product.isArchived)
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.archive_rounded,
                                                      size: 18,
                                                      color: AppColors.warning),
                                                  tooltip: 'Archive',
                                                  onPressed: () =>
                                                      _confirmArchive(
                                                          context, product),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                )
                                              else
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.unarchive_rounded,
                                                      size: 18,
                                                      color: AppColors.success),
                                                  tooltip: 'Khôi phục',
                                                  onPressed: () => context
                                                      .read<AdminProductProvider>()
                                                      .restoreProduct(
                                                          product.id),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }

                          // ── Desktop: DataTable ──────────────────────
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                        const Color(0xFFF8F9FB)),
                                    columns: const [
                                      DataColumn(
                                          label: Text('Sản phẩm',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700))),
                                      DataColumn(
                                          label: Text('Danh mục',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700))),
                                      DataColumn(
                                          label: Text('Giá',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700))),
                                      DataColumn(
                                          label: Text('Rating',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700))),
                                      DataColumn(
                                          label: Text('Tags',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700))),
                                      DataColumn(
                                          label: Text('Trạng thái',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700))),
                                      DataColumn(
                                          label: Text('Thao tác',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700))),
                                    ],
                                    rows: provider.products.map((product) {
                                      final catName = provider.categories
                                          .firstWhere(
                                            (c) => c.id == product.categoryId,
                                            orElse: () => const CategoryModel(
                                              id: '',
                                              name: '—',
                                              displayOrder: 0,
                                              isActive: true,
                                            ),
                                          )
                                          .name;
                                      return DataRow(cells: [
                                        DataCell(Row(children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors.beigeWarm,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: product.imageUrl != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    child: Image.network(
                                                      product.imageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) =>
                                                          const Icon(Icons.coffee,
                                                              color: AppColors
                                                                  .brownAccent),
                                                    ),
                                                  )
                                                : const Icon(Icons.coffee,
                                                    color: AppColors.brownAccent),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(product.name,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13)),
                                              if (product.isArchived)
                                                const Text('Đã archive',
                                                    style: TextStyle(
                                                        color: AppColors.textHint,
                                                        fontSize: 11)),
                                            ],
                                          ),
                                        ])),
                                        DataCell(Text(catName,
                                            style: const TextStyle(fontSize: 13))),
                                        DataCell(Text(
                                          fmt.format(product.basePrice),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.brownAccent,
                                            fontSize: 13,
                                          ),
                                        )),
                                        DataCell(Row(children: [
                                          const Icon(Icons.star_rounded,
                                              color: AppColors.goldPrimary,
                                              size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                              product.avgRating.toStringAsFixed(1),
                                              style:
                                                  const TextStyle(fontSize: 13)),
                                        ])),
                                        DataCell(product.tags.isEmpty
                                            ? const Text('—',
                                                style: TextStyle(
                                                    color: AppColors.textHint))
                                            : Wrap(
                                                spacing: 4,
                                                children: product.tags
                                                    .map((t) => _TagChip(tag: t))
                                                    .toList(),
                                              )),
                                        DataCell(Row(children: [
                                          Switch(
                                            value: product.isAvailable &&
                                                !product.isArchived,
                                            onChanged: product.isArchived
                                                ? null
                                                : (v) => context
                                                    .read<AdminProductProvider>()
                                                    .toggleAvailability(
                                                        product.id, v),
                                            activeThumbColor: AppColors.success,
                                          ),
                                          Text(
                                            product.isArchived
                                                ? 'Archive'
                                                : product.isAvailable
                                                    ? 'Có bán'
                                                    : 'Hết hàng',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: product.isArchived
                                                  ? AppColors.textHint
                                                  : product.isAvailable
                                                      ? AppColors.success
                                                      : AppColors.warning,
                                            ),
                                          ),
                                        ])),
                                        DataCell(Row(children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_rounded,
                                                size: 18,
                                                color: AppColors.brownAccent),
                                            tooltip: 'Sửa',
                                            onPressed: () => context.go(
                                                '/products/${product.id}/edit'),
                                          ),
                                          if (!product.isArchived)
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.archive_rounded,
                                                  size: 18,
                                                  color: AppColors.warning),
                                              tooltip: 'Archive',
                                              onPressed: () =>
                                                  _confirmArchive(context, product),
                                            )
                                          else
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.unarchive_rounded,
                                                  size: 18,
                                                  color: AppColors.success),
                                              tooltip: 'Khôi phục',
                                              onPressed: () => context
                                                  .read<AdminProductProvider>()
                                                  .restoreProduct(product.id),
                                            ),
                                        ])),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmArchive(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận Archive'),
        content: Text(
            'Sản phẩm "${product.name}" sẽ bị ẩn khỏi menu. Bạn có thể khôi phục sau.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminProductProvider>().archiveProduct(product.id);
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brownAccent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.brownAccent : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Tag Chip ─────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (tag) {
      case 'bestseller':
        color = AppColors.goldPrimary;
        break;
      case 'new':
        color = AppColors.success;
        break;
      case 'hot':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textHint;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        tag,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu_rounded,
              size: 72, color: AppColors.borderLight),
          const SizedBox(height: 16),
          const Text(
            'Chưa có sản phẩm nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bắt đầu thêm sản phẩm vào menu của bạn',
            style: TextStyle(color: AppColors.textHint),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm sản phẩm đầu tiên'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownAccent,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
