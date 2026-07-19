import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:provider/provider.dart';
import '../../cart/providers/cart_provider.dart';

/// Một bảng điều khiển chuyên biệt dành riêng cho Giáo viên / Người làm giáo dục.
/// Thiết kế tối ưu hóa độ tương phản (WCAG AAA), hỗ trợ đặt hàng cực nhanh giữa giờ nghỉ,
/// giới thiệu Combo chấm bài, lọc bàn làm việc có ổ cắm, và viết lời nhắn lên cốc.
class TeacherSpecialPanel extends StatefulWidget {
  const TeacherSpecialPanel({super.key});

  @override
  State<TeacherSpecialPanel> createState() => _TeacherSpecialPanelState();
}

class _TeacherSpecialPanelState extends State<TeacherSpecialPanel> {
  final TextEditingController _cupNoteController = TextEditingController();
  String _selectedSeatType = 'Tất cả';
  final int _currentStamps = 3; // Giả lập giáo viên đã tích 3 dấu

  @override
  void dispose() {
    _cupNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header chào mừng trang trọng và ấm áp
            _buildAcademicHeader(),
            const SizedBox(height: 24),

            // 1. Loyalty Card: Thẻ Tích Điểm Tri Ân Nhà Giáo
            _buildTeacherLoyaltyCard(),
            const SizedBox(height: 28),

            // 2. Fast Fuel / Quick Order Widget (Đặt hàng siêu tốc 5 phút)
            _buildFastFuelSection(context),
            const SizedBox(height: 28),

            // 3. Grading Companion Combo (Gợi ý Combo chấm bài đắc lực)
            _buildGradingComboSection(context),
            const SizedBox(height: 28),

            // 4. Quiet Zone / Seat Booking Tags
            _buildQuietZoneSection(),
            const SizedBox(height: 28),

            // 5. Custom Note on Cup (Viết lời chúc lên cốc tiếp thêm động lực)
            _buildCustomCupNoteSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.school, color: AppColors.goldPrimary, size: 28),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'CHẾ ĐỘ GIÁO VIÊN',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Tiếp Năng Lượng Cho Tiết Học Mới',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Thiết kế giao diện chữ lớn tương phản cao, tối giản để bảo vệ mắt giáo viên sau giờ chấm bài.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherLoyaltyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brownAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brownAccent.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'THẺ TRI ÂN NHÀ GIÁO',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.goldLight, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ƯU ĐÃI 15%',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tích 5 cốc tặng 1 cốc miễn phí dành riêng cho tài khoản nhà giáo.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final isStamped = index < _currentStamps;
              final isFreeCup = index == 5;

              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isStamped ? AppColors.goldPrimary : Colors.white10,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isStamped ? AppColors.goldLight : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isFreeCup
                      ? Icon(
                          Icons.card_giftcard,
                          color: isStamped ? Colors.white : AppColors.goldLight,
                          size: 20,
                        )
                      : (isStamped
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bạn đã tích lũy $_currentStamps/5 cốc',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Text(
                'Còn 2 cốc nữa để nhận quà!',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFastFuelSection(BuildContext context) {
    // Lọc nhanh 3 món cà phê đậm, mạnh, pha nhanh cho giáo viên tiếp năng lượng siêu tốc
    final fastFuelProducts = [
      const ProductModel(
        id: 'fast_01',
        name: 'Espresso Double Shot',
        categoryId: 'A1ZglutP5091IkqOZga1',
        basePrice: 35000.0,
        description: 'Đậm đà nguyên chất từ hạt Fine Robusta, pha chế nhanh dưới 1 phút.',
        imageUrl: 'https://images.unsplash.com/photo-1510707513156-46c31e09598a',
        tags: ['Pha cực nhanh', 'Đậm vị'],
      ),
      const ProductModel(
        id: 'fast_02',
        name: 'Cà Phê Sữa Đá Đậm Đặc',
        categoryId: 'A1ZglutP5091IkqOZga1',
        basePrice: 29000.0,
        description: 'Tỉnh táo tức thì cho tiết học tiếp theo, vị truyền thống đậm béo.',
        imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd',
        tags: ['Bán chạy', 'Caffeine cao'],
      ),
      const ProductModel(
        id: 'fast_03',
        name: 'Americano Đá Không Đường',
        categoryId: 'A1ZglutP5091IkqOZga1',
        basePrice: 35000.0,
        description: 'Thanh lọc, ít calo, dễ uống ngụm lớn khi đang đứng lớp.',
        imageUrl: 'https://images.unsplash.com/photo-1551046713-b45fdb3a228a',
        tags: ['Giải nhiệt', 'Dễ uống'],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚡ Fast Fuel — Nạp Nhanh 5 Phút',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pha chế thần tốc để kịp giờ lên lớp giảng bài',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade800.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.amber.shade900, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    'ƯU TIÊN LÀM TRƯỚC',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fastFuelProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = fastFuelProducts[index];
              return Container(
                width: 260,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl ?? '',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          color: AppColors.backgroundAlt,
                          child: const Icon(Icons.coffee, color: AppColors.textHint),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${product.basePrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{3})+(?!\d)'), (Match m) => '${m[0]}.')}đ',
                                style: const TextStyle(
                                  color: AppColors.brownAccent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.goldPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  minimumSize: const Size(60, 28),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.read<CartProvider>().addItem(
                                        product,
                                        {'Size': 'M', 'Đá': 'Thường', 'Đường': 'Thường'},
                                        0.0,
                                        1,
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã thêm ${product.name} vào giỏ hàng siêu tốc!'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'LẤY NGAY',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradingComboSection(BuildContext context) {
    const comboProduct = ProductModel(
      id: 'combo_grading',
      name: 'Combo Chấm Bài Đắc Lực',
      categoryId: 'cOQPqGseTCNScIQwBgtn',
      basePrice: 49000.0,
      description: 'Combo tiết kiệm năng lượng: 01 Cà phê sữa đá truyền thống đậm đặc giúp tỉnh táo sâu kết hợp cùng 01 Bánh Sừng Bò Croissant Pháp giòn tan lót dạ cực tốt.',
      imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348',
      tags: ['Đánh giá tốt', 'Bánh & Nước'],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📚 Combo Đồng Hành Chấm Bài & Soạn Giáo Án',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Lót dạ nhẹ nhàng và giữ sự tập trung cao độ khi làm việc tại quán',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  comboProduct.imageUrl ?? '',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: AppColors.backgroundAlt,
                    child: const Icon(Icons.menu_book, size: 50, color: AppColors.textHint),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'COMBO SOẠN ĐỀ',
                            style: TextStyle(
                              color: Colors.teal.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Text(
                          'Tiết kiệm 15k',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comboProduct.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comboProduct.description ?? '',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '49.000đ',
                              style: TextStyle(
                                color: AppColors.brownAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Giá gốc 64.000đ',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brownAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.read<CartProvider>().addItem(
                                  comboProduct,
                                  {},
                                  0.0,
                                  1,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm Combo Chấm Bài vào giỏ hàng!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text(
                            'ĐẶT COMBO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuietZoneSection() {
    final seatTypes = ['Tất cả', 'Có ổ cắm điện', 'Khu vực yên tĩnh', 'Gần cửa sổ'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔍 Chọn Không Gian Soạn Bài & Chấm Điểm',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Lọc nhanh góc ngồi yên tĩnh, có ổ cắm để bạn tập trung cao độ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: seatTypes.map((type) {
            final isSelected = _selectedSeatType == type;
            return ChoiceChip(
              label: Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.brownAccent,
              backgroundColor: AppColors.cardBackground,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.borderLight,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSeatType = type;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.beigeWarm,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.brownAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    children: [
                      const TextSpan(text: 'Khuyên dùng: '),
                      TextSpan(
                        text: _selectedSeatType == 'Tất cả'
                            ? 'Khu vực tầng 2 bên trái hiện đang cực kỳ yên tĩnh (30dB) và còn nhiều bàn lớn sát ổ cắm điện phù hợp để laptop soạn giáo án.'
                            : 'Bộ lọc "$_selectedSeatType" đang hiển thị các vị trí lý tưởng với độ ồn < 40dB tại lầu 1 và lầu 2.',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCupNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '✍️ Viết Lời Nhắn Lên Cốc Giấy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Lời chúc tiếp sức tinh thần để barista in nổi lên thân cốc tiếp thêm năng lượng',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cupNoteController,
          maxLength: 60,
          decoration: InputDecoration(
            hintText: 'Ví dụ: "Happy Monday, cô giáo!", "Chúc thầy buổi chiều vui vẻ!"',
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.cardBackground,
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
              borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
            ),
            counterText: '',
          ),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.local_cafe_outlined, color: AppColors.goldPrimary, size: 16),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                'Nội dung này sẽ được chuyển trực tiếp đến máy in tem dán cốc của barista.',
                style: TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
