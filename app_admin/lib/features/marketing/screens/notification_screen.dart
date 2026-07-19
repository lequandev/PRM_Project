import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'all';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final dtFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildComposePanel(provider),
                      const SizedBox(height: 24),
                      _buildHistoryPanel(provider, dtFmt),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildComposePanel(provider),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 340,
                        height: MediaQuery.of(context).size.height - 80,
                        child: _buildHistoryPanel(provider, dtFmt),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildComposePanel(NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gửi Push Notification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.brownAccent,
          ),
        ),
        const Text(
          'Gửi thông báo tới tất cả hoặc nhóm khách hàng',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target
              const Text('Đối tượng gửi',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 10),
              LayoutBuilder(builder: (ctx, bc) {
                return SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'all',
                      icon: Icon(Icons.people_rounded),
                      label: Text('Tất cả'),
                    ),
                    ButtonSegment(
                      value: 'customer',
                      icon: Icon(Icons.person_rounded),
                      label: Text('Thường xuyên'),
                    ),
                  ],
                  selected: {_target},
                  onSelectionChanged: (s) =>
                      setState(() => _target = s.first),
                );
              }),
              const SizedBox(height: 20),

              // Title
              const Text('Tiêu đề *',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: _inputDeco('VD: Ưu đãi cuối tuần 🎉'),
                maxLength: 65,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Body
              const Text('Nội dung *',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _bodyCtrl,
                maxLines: 4,
                maxLength: 200,
                decoration: _inputDeco('Nội dung thông báo chi tiết...'),
                onChanged: (_) => setState(() {}),
              ),

              // Feedback messages
              if (provider.successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(provider.successMessage!,
                            style: const TextStyle(
                                color: AppColors.success)),
                      ),
                    ],
                  ),
                ),
              if (provider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(provider.errorMessage!,
                      style: const TextStyle(color: AppColors.error)),
                ),

              const SizedBox(height: 20),

              // Preview card
              if (_titleCtrl.text.isNotEmpty || _bodyCtrl.text.isNotEmpty)
                _buildPreview(),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: provider.isSending
                      ? null
                      : () async {
                          if (_titleCtrl.text.trim().isEmpty ||
                              _bodyCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  'Vui lòng nhập tiêu đề và nội dung'),
                              backgroundColor: AppColors.error,
                            ));
                            return;
                          }
                          final ok = await provider.sendNotification(
                            title: _titleCtrl.text.trim(),
                            body: _bodyCtrl.text.trim(),
                            target: _target,
                          );
                          if (ok && mounted) {
                            _titleCtrl.clear();
                            _bodyCtrl.clear();
                            setState(() {});
                          }
                        },
                  icon: provider.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(provider.isSending
                      ? 'Đang gửi...'
                      : 'Gửi thông báo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brownAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryPanel(NotificationProvider provider, DateFormat dtFmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch sử gửi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brownAccent,
          ),
        ),
        const SizedBox(height: 16),
        provider.history.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                    child: Text('Chưa có thông báo nào',
                        style: TextStyle(color: AppColors.textHint))),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final n = provider.history[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                                Icons.notifications_active_rounded,
                                size: 16,
                                color: AppColors.goldPrimary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                n.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          n.body,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.brownAccent
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                n.target == 'all'
                                    ? 'Tất cả'
                                    : 'Thường xuyên',
                                style: const TextStyle(
                                  color: AppColors.brownAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              dtFmt.format(n.sentAt),
                              style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone_android_rounded,
                  color: Colors.white54, size: 14),
              SizedBox(width: 6),
              Text('Preview thông báo',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_cafe_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleCtrl.text.isEmpty
                            ? 'Tiêu đề...'
                            : _titleCtrl.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _bodyCtrl.text.isEmpty
                            ? 'Nội dung...'
                            : _bodyCtrl.text,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
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
    );
  }
}
