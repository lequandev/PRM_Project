import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:intl/intl.dart';
import '../providers/voucher_provider.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  bool _showCreateForm = false;

  // Form
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _maxDiscountCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _usageLimitCtrl = TextEditingController();
  final _perUserCtrl = TextEditingController(text: '1');
  String _discountType = 'percentage';
  DateTime _startDate = DateTime.now();
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _minOrderCtrl.dispose();
    _usageLimitCtrl.dispose();
    _perUserCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VoucherProvider>();
    final fmt = NumberFormat.currency(
        locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final dtFmt = DateFormat('dd/MM/yyyy');

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
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Voucher',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownAccent,
                      ),
                    ),
                    Text(
                      'Tạo và quản lý mã giảm giá cho khách hàng',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      setState(() => _showCreateForm = !_showCreateForm),
                  icon: Icon(
                      _showCreateForm
                          ? Icons.close_rounded
                          : Icons.add_rounded,
                      size: 18),
                  label: Text(_showCreateForm ? 'Đóng' : 'Tạo Voucher'),
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
            const SizedBox(height: 20),

            // Toggle between showing Create Form and Voucher List to prevent vertical overflow
            Expanded(
              child: _showCreateForm
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildCreateForm(context, provider),
                    )
                  : provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.vouchers.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_offer_rounded,
                                      size: 60, color: AppColors.borderLight),
                                  SizedBox(height: 12),
                                  Text('Chưa có voucher nào',
                                      style: TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 16)),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 380,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                mainAxisExtent: 235,
                              ),
                              itemCount: provider.vouchers.length,
                              itemBuilder: (context, i) {
                                final v = provider.vouchers[i];
                                final isExpired =
                                    v.expiresAt.isBefore(DateTime.now());
                                return _VoucherCard(
                                  voucher: v,
                                  isExpired: isExpired,
                                  fmt: fmt,
                                  dtFmt: dtFmt,
                                  onToggle: () async {
                                    if (v.isActive) {
                                      await provider.deactivateVoucher(v.code);
                                    } else {
                                      await provider.activateVoucher(v.code);
                                    }
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm(BuildContext context, VoucherProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tạo Voucher mới',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.brownAccent)),
          const SizedBox(height: 16),

          // Row 1: Code + Description
          LayoutBuilder(builder: (ctx, bc) {
            final isMobile = bc.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  _field('Mã Voucher *', _codeCtrl, hint: 'VD: SUMMER30'),
                  const SizedBox(height: 12),
                  _field('Mô tả', _descCtrl, hint: 'Giảm 30% hè 2026'),
                ],
              );
            }
            return Row(children: [
              Expanded(child: _field('Mã Voucher *', _codeCtrl, hint: 'VD: SUMMER30')),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _field('Mô tả', _descCtrl, hint: 'Giảm 30% hè 2026')),
            ]);
          }),
          const SizedBox(height: 12),

          // Discount type toggle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Loại giảm',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _typeChip('Phần trăm %', 'percentage'),
                  const SizedBox(width: 8),
                  _typeChip('Cố định ₫', 'fixed'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: numeric fields — Wrap so they flow to next line on mobile
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _numField(
                _discountType == 'percentage' ? 'Giá trị (%)' : 'Giá trị (₫)',
                _valueCtrl,
                hint: '20',
              ),
              if (_discountType == 'percentage')
                _numField('Giảm tối đa (₫)', _maxDiscountCtrl, hint: '50000'),
              _numField('Đơn hàng tối thiểu (₫)', _minOrderCtrl, hint: '50000'),
              _numField('Giới hạn dùng', _usageLimitCtrl, hint: '100'),
              _numField('Mỗi user', _perUserCtrl, hint: '1'),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: dates + submit
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _datePicker('Bắt đầu', _startDate,
                  (d) => setState(() => _startDate = d)),
              _datePicker('Hết hạn', _expiresAt,
                  (d) => setState(() => _expiresAt = d)),
              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        if (_codeCtrl.text.trim().isEmpty ||
                            _valueCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mã voucher và giá trị là bắt buộc'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        final voucher = VoucherModel(
                          code: _codeCtrl.text.trim().toUpperCase(),
                          description: _descCtrl.text.trim(),
                          discountType: _discountType,
                          discountValue: double.tryParse(
                                  _valueCtrl.text.replaceAll(',', '')) ??
                              0,
                          maxDiscountAmount: _maxDiscountCtrl.text.isNotEmpty
                              ? double.tryParse(_maxDiscountCtrl.text)
                              : null,
                          minOrderValue:
                              double.tryParse(_minOrderCtrl.text) ?? 0,
                          usageLimit: _usageLimitCtrl.text.isNotEmpty
                              ? int.tryParse(_usageLimitCtrl.text)
                              : null,
                          perUserLimit:
                              int.tryParse(_perUserCtrl.text) ?? 1,
                          isActive: true,
                          startDate: _startDate,
                          expiresAt: _expiresAt,
                        );
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await provider.createVoucher(voucher);
                        if (ok && mounted) {
                          setState(() => _showCreateForm = false);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Tạo voucher thành công!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brownAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Tạo Voucher',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Small toggle chip for discount type
  Widget _typeChip(String label, String value) {
    final selected = _discountType == value;
    return GestureDetector(
      onTap: () => setState(() => _discountType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.brownAccent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.brownAccent
                : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Fixed-width labeled number field for Wrap layout
  Widget _numField(String label, TextEditingController ctrl,
      {String hint = ''}) {
    return SizedBox(
      width: 150,
      child: _field(label, ctrl, hint: hint),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.backgroundAlt,
            isDense: true,
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
          ),
        ),
      ],
    );
  }

  Widget _datePicker(
      String label, DateTime date, void Function(DateTime) onPick) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now().subtract(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onPick(picked);
          },
          icon: const Icon(Icons.calendar_today_rounded, size: 16),
          label: Text(fmt.format(date), style: const TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.borderLight),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

// ─── Voucher Card ─────────────────────────────────────────────────────────────

class _VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final bool isExpired;
  final NumberFormat fmt;
  final DateFormat dtFmt;
  final VoidCallback onToggle;

  const _VoucherCard({
    required this.voucher,
    required this.isExpired,
    required this.fmt,
    required this.dtFmt,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final v = voucher;
    Color statusColor = v.isActive && !isExpired
        ? AppColors.success
        : isExpired
            ? AppColors.textHint
            : AppColors.error;

    String statusLabel = v.isActive && !isExpired
        ? 'Đang hoạt động'
        : isExpired
            ? 'Hết hạn'
            : 'Đã tắt';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: v.isActive && !isExpired
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brownAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    v.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            v.description,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.discount_rounded,
                  color: AppColors.goldPrimary, size: 16),
              const SizedBox(width: 6),
              Text(
                v.discountType == 'percentage'
                    ? '${v.discountValue.toInt()}%'
                    : fmt.format(v.discountValue),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.brownAccent,
                ),
              ),
              if (v.maxDiscountAmount != null) ...[
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '(tối đa ${fmt.format(v.maxDiscountAmount!)})',
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Đơn tối thiểu: ${fmt.format(v.minOrderValue)} • ${dtFmt.format(v.startDate)} → ${dtFmt.format(v.expiresAt)}',
            style: const TextStyle(
                color: AppColors.textHint, fontSize: 10),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'Đã dùng: ${v.usageCount}${v.usageLimit != null ? '/${v.usageLimit}' : ''}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
              const Spacer(),
              if (!isExpired)
                Switch(
                  value: v.isActive,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppColors.success,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}


