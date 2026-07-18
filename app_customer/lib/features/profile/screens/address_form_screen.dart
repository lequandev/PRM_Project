import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/profile_repository.dart';
import '../providers/address_provider.dart';

/// AddressFormScreen — UC-05: thêm mới ([initial] == null) hoặc sửa địa chỉ.
class AddressFormScreen extends StatelessWidget {
  const AddressFormScreen({super.key, this.initial});

  final AddressModel? initial;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddressProvider(context.read<ProfileRepository>()),
      child: _AddressFormView(initial: initial),
    );
  }
}

class _AddressFormView extends StatefulWidget {
  const _AddressFormView({this.initial});

  final AddressModel? initial;

  @override
  State<_AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<_AddressFormView> {
  static const _suggestions = ['Nhà', 'Cơ quan', 'Khác'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _streetController;
  late final TextEditingController _wardController;
  late final TextEditingController _districtController;
  late final TextEditingController _cityController;
  late bool _isDefault;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _labelController = TextEditingController(text: a?.label ?? '');
    _streetController = TextEditingController(text: a?.street ?? '');
    _wardController = TextEditingController(text: a?.ward ?? '');
    _districtController = TextEditingController(text: a?.district ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  bool _isChipSelected(String suggestion) {
    final label = _labelController.text.trim();
    if (suggestion == 'Khác') {
      return label.isNotEmpty && !_suggestions.contains(label);
    }
    return label == suggestion;
  }

  void _onChipTap(String suggestion) {
    setState(() {
      _labelController.text = suggestion == 'Khác' ? '' : suggestion;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<AddressProvider>();

    final address = AddressModel(
      // Giữ nguyên id khi sửa; id '' khi tạo — repo tự sinh.
      id: widget.initial?.id ?? '',
      label: _labelController.text.trim(),
      street: _streetController.text.trim(),
      ward: _wardController.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      isDefault: _isDefault,
      lat: widget.initial?.lat,
      lng: widget.initial?.lng,
    );

    final ok = _isEditing
        ? await provider.updateAddress(address)
        : await provider.addAddress(address);
    if (!mounted) return;

    if (ok) {
      // Root ScaffoldMessenger nên SnackBar vẫn hiển thị sau khi pop.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content:
              Text(_isEditing ? 'Đã cập nhật địa chỉ' : 'Đã thêm địa chỉ mới'),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(provider.error ?? 'Lưu địa chỉ thất bại.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<AddressProvider>().isSaving;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa địa chỉ' : 'Thêm địa chỉ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Tên gợi nhớ',
              style: AppTypography.label
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final suggestion in _suggestions)
                  ChoiceChip(
                    label: Text(suggestion),
                    selected: _isChipSelected(suggestion),
                    selectedColor: AppColors.goldPrimary,
                    labelStyle: AppTypography.buttonSmall.copyWith(
                      color: _isChipSelected(suggestion)
                          ? AppColors.textOnGold
                          : AppColors.textSecondary,
                    ),
                    onSelected: (_) => _onChipTap(suggestion),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _labelController,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Tên gợi nhớ'),
              decoration: const InputDecoration(
                hintText: 'VD: Nhà, Trường, Nhà bạn thân…',
                prefixIcon: Icon(Icons.bookmark_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _streetController,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Số nhà, tên đường'),
              decoration: const InputDecoration(
                labelText: 'Số nhà, tên đường',
                hintText: 'VD: 123 Nguyễn Văn Linh',
                prefixIcon: Icon(Icons.signpost_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _wardController,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Phường/Xã'),
              decoration: const InputDecoration(
                labelText: 'Phường/Xã',
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _districtController,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Quận/Huyện'),
              decoration: const InputDecoration(
                labelText: 'Quận/Huyện',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cityController,
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Tỉnh/Thành phố'),
              decoration: const InputDecoration(
                labelText: 'Tỉnh/Thành phố',
                prefixIcon: Icon(Icons.public_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: SwitchListTile(
                value: _isDefault,
                activeThumbColor: AppColors.goldPrimary,
                title: const Text('Đặt làm mặc định',
                    style: AppTypography.bodyLarge),
                subtitle: Text(
                  'Tự động chọn địa chỉ này khi giao hàng',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textHint),
                ),
                onChanged: (value) => setState(() => _isDefault = value),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.textOnGold,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            onPressed: isSaving ? null : _save,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Lưu thay đổi' : 'Lưu địa chỉ',
                    style: AppTypography.button),
          ),
        ),
      ),
    );
  }
}
