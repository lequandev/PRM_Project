import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../providers/admin_product_provider.dart';

/// ProductFormScreen — Tạo mới (UC-31) hoặc Sửa sản phẩm (UC-32).
/// Dùng chung một màn hình: nếu [editProductId] == null → tạo mới.
class ProductFormScreen extends StatefulWidget {
  final String? editProductId;
  const ProductFormScreen({super.key, this.editProductId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  // State
  String _selectedCategoryId = '';
  bool _isAvailable = true;
  List<String> _tags = [];
  bool _isLoading = false;
  ProductModel? _editingProduct;

  bool get _isEditing => widget.editProductId != null;

  final List<String> _availableTags = ['bestseller', 'new', 'hot'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
    }
  }

  void _loadProduct() {
    final provider = context.read<AdminProductProvider>();
    final product = provider.products
        .cast<ProductModel?>()
        .firstWhere((p) => p?.id == widget.editProductId, orElse: () => null);
    if (product != null) {
      setState(() {
        _editingProduct = product;
        _nameCtrl.text = product.name;
        _descCtrl.text = product.description ?? '';
        _priceCtrl.text = product.basePrice.toStringAsFixed(0);
        _selectedCategoryId = product.categoryId;
        _isAvailable = product.isAvailable;
        _tags = List.from(product.tags);
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId.isEmpty) {
      _showSnack('Vui lòng chọn danh mục', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final provider = context.read<AdminProductProvider>();
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0;

    bool ok;
    if (_isEditing && _editingProduct != null) {
      final updated = _editingProduct!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        basePrice: price,
        categoryId: _selectedCategoryId,
        isAvailable: _isAvailable,
        tags: _tags,
      );
      ok = await provider.updateProduct(updated);
    } else {
      final newProduct = ProductModel(
        id: '',
        name: _nameCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        basePrice: price,
        categoryId: _selectedCategoryId,
        isAvailable: _isAvailable,
        isArchived: false,
        tags: _tags,
      );
      ok = await provider.createProduct(newProduct);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (ok) {
        _showSnack(
            _isEditing ? 'Cập nhật thành công!' : 'Tạo sản phẩm thành công!');
        context.go('/products');
      } else {
        _showSnack(
            provider.errorMessage ?? 'Có lỗi xảy ra', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go('/products'),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brownAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: LayoutBuilder(
                builder: (context, bc) {
                  final isMobile = bc.maxWidth < 700;
                  final formPanel = Container(
                    padding: const EdgeInsets.all(24),
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
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Thông tin cơ bản',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brownAccent,
                                )),
                            const SizedBox(height: 20),

                            // Name
                            _FormField(
                              label: 'Tên sản phẩm *',
                              child: TextFormField(
                                controller: _nameCtrl,
                                decoration: _inputDeco(hint: 'VD: Cà phê sữa đá'),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Vui lòng nhập tên sản phẩm'
                                    : null,
                              ),
                            ),

                            // Description
                            _FormField(
                              label: 'Mô tả',
                              child: TextFormField(
                                controller: _descCtrl,
                                maxLines: 3,
                                decoration: _inputDeco(hint: 'Mô tả ngắn về sản phẩm...'),
                              ),
                            ),

                            // Price
                            _FormField(
                              label: 'Giá cơ bản (VNĐ) *',
                              child: TextFormField(
                                controller: _priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDeco(hint: 'VD: 35000'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Vui lòng nhập giá';
                                  }
                                  final price = double.tryParse(v.replaceAll(',', ''));
                                  if (price == null || price <= 0) {
                                    return 'Giá không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            // Category
                            _FormField(
                              label: 'Danh mục *',
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategoryId.isEmpty
                                    ? null
                                    : _selectedCategoryId,
                                hint: const Text('Chọn danh mục'),
                                decoration: _inputDeco(hint: ''),
                                items: provider.categories
                                    .map((c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedCategoryId = v ?? ''),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            // Tags
                            _FormField(
                              label: 'Tags',
                              child: Wrap(
                                spacing: 8,
                                children: _availableTags.map((tag) {
                                  final selected = _tags.contains(tag);
                                  return FilterChip(
                                    label: Text(tag),
                                    selected: selected,
                                    onSelected: (v) {
                                      setState(() {
                                        if (v) {
                                          _tags.add(tag);
                                        } else {
                                          _tags.remove(tag);
                                        }
                                      });
                                    },
                                    selectedColor: AppColors.goldLight,
                                    checkmarkColor: AppColors.brownAccent,
                                  );
                                }).toList(),
                              ),
                            ),

                            // Available switch
                            _FormField(
                              label: 'Trạng thái',
                              child: Row(
                                children: [
                                  Switch(
                                    value: _isAvailable,
                                    onChanged: (v) =>
                                        setState(() => _isAvailable = v),
                                    activeThumbColor: AppColors.success,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isAvailable ? 'Đang bán' : 'Tạm ngưng',
                                    style: TextStyle(
                                      color: _isAvailable
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  final actionsPanel = Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Hành động',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.brownAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brownAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _isEditing ? 'Lưu thay đổi' : 'Tạo sản phẩm',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => context.go('/products'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Hủy',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  );

                  if (isMobile) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          actionsPanel,
                          const SizedBox(height: 16),
                          formPanel,
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: formPanel),
                      const SizedBox(width: 20),
                      SizedBox(width: 260, child: actionsPanel),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.backgroundAlt,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.brownAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}


