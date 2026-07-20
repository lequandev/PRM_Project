import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _showAddForm = false;

  // Add ingredient form controllers
  final _addNameCtrl = TextEditingController();
  final _addUnitCtrl = TextEditingController();
  final _addStockCtrl = TextEditingController();
  final _addMinStockCtrl = TextEditingController();

  @override
  void dispose() {
    _addNameCtrl.dispose();
    _addUnitCtrl.dispose();
    _addStockCtrl.dispose();
    _addMinStockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Kho hàng',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownAccent,
                      ),
                    ),
                    Text(
                      'Theo dõi và cập nhật tồn kho nguyên liệu realtime',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (provider.lowStockCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.error, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${provider.lowStockCount} nguyên liệu sắp/hết hàng',
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          setState(() => _showAddForm = !_showAddForm),
                      icon: Icon(
                          _showAddForm ? Icons.close_rounded : Icons.add_rounded,
                          size: 18),
                      label: Text(_showAddForm ? 'Đóng' : 'Thêm nguyên liệu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brownAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add ingredient form
            if (_showAddForm) _buildAddForm(context, provider),

            // Error
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
                    Text(provider.errorMessage!,
                        style: const TextStyle(color: AppColors.error)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.error, size: 18),
                      onPressed: provider.clearError,
                    ),
                  ],
                ),
              ),

            // Table & Mobile list responsive
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.ingredients.isEmpty
                      ? const Center(
                          child: Text('Chưa có nguyên liệu nào',
                              style: TextStyle(color: AppColors.textHint)))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 700;
                            if (isMobile) {
                              return ListView.builder(
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: provider.ingredients.length,
                                itemBuilder: (context, index) {
                                  return _IngredientRow(
                                    ingredient: provider.ingredients[index],
                                    onUpdate: (newStock) async {
                                      await provider.updateStock(
                                        ingredientId: provider.ingredients[index].id,
                                        newStock: newStock,
                                        updatedBy: 'admin',
                                      );
                                    },
                                  );
                                },
                              );
                            }

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
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 800,
                                      maxWidth: constraints.maxWidth > 800
                                          ? constraints.maxWidth
                                          : 800,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          // Table header
                                          Container(
                                            color: const Color(0xFFF8F9FB),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 14),
                                            child: const Row(
                                              children: [
                                                Expanded(
                                                    flex: 3,
                                                    child: Text('Nguyên liệu',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 13))),
                                                Expanded(
                                                    child: Text('Đơn vị',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                                fontSize: 13))),
                                                Expanded(
                                                    child: Text('Tồn kho',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                                fontSize: 13))),
                                                Expanded(
                                                    child: Text(
                                                        'Ngưỡng cảnh báo',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 13))),
                                                Expanded(
                                                    flex: 2,
                                                    child: Text('Trạng thái',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 13))),
                                                SizedBox(
                                                    width: 120,
                                                    child: Text('Cập nhật',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                                fontSize: 13))),
                                              ],
                                            ),
                                          ),
                                          const Divider(height: 1),

                                          // Table rows
                                          ...provider.ingredients.map(
                                            (ingredient) => _IngredientRow(
                                              ingredient: ingredient,
                                              onUpdate: (newStock) async {
                                                await provider.updateStock(
                                                  ingredientId: ingredient.id,
                                                  newStock: newStock,
                                                  updatedBy: 'admin',
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAddForm(BuildContext context, InventoryProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thêm nguyên liệu mới',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.brownAccent),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (ctx, bc) {
            final isMobile = bc.maxWidth < 650;

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _labeledField('Tên nguyên liệu *', _addNameCtrl,
                      hint: 'VD: Sữa tươi Barista'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _labeledField('Đơn vị', _addUnitCtrl,
                            hint: 'VD: kg, lít, hộp'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _labeledField('Tồn hiện tại', _addStockCtrl,
                            hint: '0.0', type: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _labeledField('Ngưỡng cảnh báo tối thiểu', _addMinStockCtrl,
                      hint: '1.0', type: TextInputType.number),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _submitAddIngredient(context, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brownAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Thêm nguyên liệu',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              );
            }

            // Desktop Horizontal Row Layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: _labeledField('Tên nguyên liệu *', _addNameCtrl,
                      hint: 'VD: Hạt Robusta'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _labeledField('Đơn vị', _addUnitCtrl,
                      hint: 'kg, lít...'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _labeledField('Tồn hiện tại', _addStockCtrl,
                      hint: '0', type: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _labeledField('Ngưỡng cảnh báo', _addMinStockCtrl,
                      hint: '0', type: TextInputType.number),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _submitAddIngredient(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brownAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Thêm',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Future<void> _submitAddIngredient(
      BuildContext context, InventoryProvider provider) async {
    if (_addNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên nguyên liệu là bắt buộc!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final unitStr = _addUnitCtrl.text.trim().isEmpty ? 'cái' : _addUnitCtrl.text.trim();
    final stockVal = double.tryParse(_addStockCtrl.text) ?? 0;
    final minStockVal = double.tryParse(_addMinStockCtrl.text) ?? 0;

    // Validation for discrete units
    final unitLower = unitStr.toLowerCase().trim();
    final discreteUnits = {'cái', 'chai', 'lon', 'hộp', 'túi', 'ly', 'gói', 'chiếc', 'quả'};
    if (discreteUnits.contains(unitLower)) {
      if (stockVal != stockVal.toInt() || minStockVal != minStockVal.toInt()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đơn vị "$unitStr" yêu cầu số tồn kho và ngưỡng cảnh báo phải là số nguyên!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final ingredient = IngredientModel(
      id: '',
      name: _addNameCtrl.text.trim(),
      unit: unitStr,
      currentStock: stockVal,
      minStock: minStockVal,
    );
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.addIngredient(ingredient);
    if (ok && mounted) {
      _addNameCtrl.clear();
      _addUnitCtrl.clear();
      _addStockCtrl.clear();
      _addMinStockCtrl.clear();
      setState(() => _showAddForm = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Đã thêm nguyên liệu!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _labeledField(String label, TextEditingController ctrl,
      {String hint = '', TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: _inputDeco(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.backgroundAlt,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: AppColors.brownAccent, width: 2),
      ),
    );
  }
}


// ─── Ingredient Row ───────────────────────────────────────────────────────────

class _IngredientRow extends StatefulWidget {
  final IngredientModel ingredient;
  final Future<void> Function(double) onUpdate;

  const _IngredientRow({
    required this.ingredient,
    required this.onUpdate,
  });

  @override
  State<_IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends State<_IngredientRow> {
  bool _isEditing = false;
  late TextEditingController _ctrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: _formatStock(widget.ingredient.currentStock, widget.ingredient.unit));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.ingredient.computedStatus) {
      case 'out_of_stock':
        return AppColors.error;
      case 'low':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  String get _statusLabel {
    switch (widget.ingredient.computedStatus) {
      case 'out_of_stock':
        return 'Hết hàng';
      case 'low':
        return 'Sắp hết';
      default:
        return 'Đủ hàng';
    }
  }

  Future<void> _saveStock() async {
    final text = _ctrl.text.replaceAll(',', '').trim();
    final v = double.tryParse(text);
    if (v == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vui lòng nhập số hợp lệ'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final u = widget.ingredient.unit.toLowerCase().trim();
    final discreteUnits = {'cái', 'chai', 'lon', 'hộp', 'túi', 'ly', 'gói', 'chiếc', 'quả'};
    final isDiscrete = discreteUnits.contains(u);

    if (isDiscrete && v != v.toInt()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Đơn vị "${widget.ingredient.unit}" yêu cầu số lượng là số nguyên!'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSaving = true);
    await widget.onUpdate(v);
    setState(() {
      _isEditing = false;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.ingredient;
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    i.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Tồn thực tế (${i.unit})',
                          labelStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_circle_rounded,
                              color: AppColors.success),
                      onPressed: _isSaving ? null : _saveStock,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.cancel_rounded,
                          color: AppColors.error),
                      onPressed: () =>
                          setState(() => _isEditing = false),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Đơn vị',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(i.unit,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ngưỡng tối thiểu',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text('${_formatStock(i.minStock, i.unit)} ${i.unit}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Tồn kho thực tế',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_formatStock(i.currentStock, i.unit)} ${i.unit}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _statusColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              _ctrl.text =
                                  _formatStock(i.currentStock, i.unit);
                              setState(() => _isEditing = true);
                            },
                            child: const Icon(
                              Icons.edit_rounded,
                              color: AppColors.brownAccent,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(i.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              Expanded(
                child: Text(i.unit,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
              Expanded(
                child: _isEditing
                    ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _ctrl,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      )
                    : Text(
                        '${_formatStock(i.currentStock, i.unit)} ${i.unit}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                          fontSize: 13,
                        ),
                      ),
              ),
              Expanded(
                child: Text(
                  '${_formatStock(i.minStock, i.unit)} ${i.unit}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: Row(
                  children: _isEditing
                      ? [
                          IconButton(
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.check_rounded,
                                    color: AppColors.success, size: 20),
                            onPressed: _isSaving ? null : _saveStock,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.error, size: 20),
                            onPressed: () =>
                                setState(() => _isEditing = false),
                          ),
                        ]
                      : [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded,
                                color: AppColors.brownAccent, size: 18),
                            tooltip: 'Cập nhật số lượng',
                            onPressed: () {
                              _ctrl.text = _formatStock(i.currentStock, i.unit);
                              setState(() => _isEditing = true);
                            },
                          ),
                        ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderLight),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _formatStock(double value, String unit) {
  final u = unit.toLowerCase().trim();
  final discreteUnits = {'cái', 'chai', 'lon', 'hộp', 'túi', 'ly', 'gói', 'chiếc', 'quả'};
  if (discreteUnits.contains(u)) {
    return value.toInt().toString();
  }
  // For mass/volume (kg, liters etc.), keep decimals if it has decimal part, otherwise trim it.
  if (value == value.toInt()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

