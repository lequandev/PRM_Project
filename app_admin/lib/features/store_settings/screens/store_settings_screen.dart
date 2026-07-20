import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../providers/store_config_provider.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _openCtrl = TextEditingController();
  final _closeCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _loyaltyRateCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _openCtrl.dispose();
    _closeCtrl.dispose();
    _feeCtrl.dispose();
    _minOrderCtrl.dispose();
    _loyaltyRateCtrl.dispose();
    super.dispose();
  }

  void _initFromConfig(StoreConfig config) {
    if (_initialized) return;
    _nameCtrl.text = config.storeName;
    _addressCtrl.text = config.address;
    _phoneCtrl.text = config.phone;
    _openCtrl.text = config.openTime;
    _closeCtrl.text = config.closeTime;
    _feeCtrl.text = config.deliveryFee.toStringAsFixed(0);
    _minOrderCtrl.text = config.minDeliveryOrder.toStringAsFixed(0);
    _loyaltyRateCtrl.text = (config.loyaltyRate * 100).toStringAsFixed(1);
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreConfigProvider>();

    if (provider.config != null && !_initialized) {
      _initFromConfig(provider.config!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — responsive
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
                      'Cài đặt Cửa hàng',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownAccent,
                      ),
                    ),
                    Text(
                      'Cấu hình thông tin và hoạt động của quán',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                // Store open toggle
                if (provider.config != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: provider.config!.isOpen
                                ? AppColors.success
                                : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.config!.isOpen ? 'Đang mở cửa' : 'Đang đóng cửa',
                          style: TextStyle(
                            color: provider.config!.isOpen
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Switch(
                          value: provider.config!.isOpen,
                          onChanged: (v) => provider.toggleStoreOpen(v),
                          activeThumbColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            if (provider.isLoading)
              const Expanded(
                  child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutBuilder(builder: (ctx, bc) {
                    final isMobile = bc.maxWidth < 700;

                    final leftPanel = Column(
                      children: [
                        _Section(
                          title: 'Thông tin cửa hàng',
                          icon: Icons.store_rounded,
                          children: [
                            _Field(label: 'Tên cửa hàng', child: TextField(controller: _nameCtrl, decoration: _deco('Coffee Shop'))),
                            _Field(label: 'Địa chỉ', child: TextField(controller: _addressCtrl, maxLines: 2, decoration: _deco('123 Phố Duy Tân...'))),
                            _Field(label: 'Số điện thoại', child: TextField(controller: _phoneCtrl, decoration: _deco('024 9999 8888'))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _Section(
                          title: 'Giờ hoạt động',
                          icon: Icons.schedule_rounded,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _Field(label: 'Giờ mở cửa', child: TextField(controller: _openCtrl, decoration: _deco('07:00')))),
                                const SizedBox(width: 16),
                                Expanded(child: _Field(label: 'Giờ đóng cửa', child: TextField(controller: _closeCtrl, decoration: _deco('22:00')))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );

                    final rightPanel = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Section(
                          title: 'Giao hàng & Loyalty',
                          icon: Icons.delivery_dining_rounded,
                          children: [
                            _Field(label: 'Phí giao hàng (₫)', child: TextField(controller: _feeCtrl, keyboardType: TextInputType.number, decoration: _deco('15000'))),
                            _Field(label: 'Đơn hàng tối thiểu (₫)', child: TextField(controller: _minOrderCtrl, keyboardType: TextInputType.number, decoration: _deco('50000'))),
                            _Field(
                              label: 'Tỷ lệ loyalty (%)',
                              child: TextField(
                                controller: _loyaltyRateCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _deco('1.0'),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'VD: 1% → 1 điểm / 100₫ chi tiêu',
                              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Feedback
                        if (provider.successMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(provider.successMessage!, style: const TextStyle(color: AppColors.success))),
                              ],
                            ),
                          ),
                        if (provider.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(10)),
                            child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                          ),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: provider.isSaving
                                ? null
                                : () async {
                                    final current = provider.config!;
                                    final newConfig = StoreConfig(
                                      storeName: _nameCtrl.text.trim(),
                                      address: _addressCtrl.text.trim(),
                                      phone: _phoneCtrl.text.trim(),
                                      openTime: _openCtrl.text.trim(),
                                      closeTime: _closeCtrl.text.trim(),
                                      isOpen: current.isOpen,
                                      deliveryFee: double.tryParse(_feeCtrl.text) ?? current.deliveryFee,
                                      minDeliveryOrder: double.tryParse(_minOrderCtrl.text) ?? current.minDeliveryOrder,
                                      loyaltyRate: (double.tryParse(_loyaltyRateCtrl.text) ?? 1.0) / 100,
                                    );
                                    await provider.updateConfig(newConfig);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brownAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: provider.isSaving
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : const Text('Lưu cài đặt', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ),
                      ],
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          leftPanel,
                          const SizedBox(height: 16),
                          rightPanel,
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: leftPanel),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: rightPanel),
                      ],
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.backgroundAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderLight)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.brownAccent, width: 2)),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.brownAccent, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.brownAccent)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}


