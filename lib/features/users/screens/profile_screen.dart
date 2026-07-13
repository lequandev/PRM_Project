import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../services/user_service.dart';
import '../widgets/digital_reward_card.dart';
import '../widgets/profile_accordion_tile.dart';

class LuxeColors {
  static const goldPrimary = Color(0xFFD4AF37);
  static const bgDark = Color(0xFF121212);
  static const bgLight = Color(0xFFF9F9F9);
  static const cardDark = Color(0xFF1E1E1E);
}

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final VoidCallback onLogout;
  final VoidCallback
  onProfileUpdated; // Callback báo hiệu tải lại data thành công nếu cần

  const ProfileScreen({
    super.key,
    required this.user,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.onLogout,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService(); // Khởi tạo Service
  bool _isEditing = false;
  bool _isSaving = false;
  String? _activeSection = 'address';

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late List<TextEditingController> _addressControllers;
  File? _selectedAvatarFile;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.user.fullname);
    _emailController = TextEditingController(text: widget.user.email);
    _addressControllers = widget.user.savedAddresses
        .map((addr) => TextEditingController(text: addr.address))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    for (var c in _addressControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    if (!_isEditing) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _selectedAvatarFile = File(pickedFile.path));
    }
  }

  IconData _getAddressIcon(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Icons.home_outlined;
      case AddressType.work:
        return Icons.badge_outlined;
      case AddressType.other:
        return Icons.public;
    }
  }

  void _handleSaveChanges() async {
    setState(() => _isSaving = true);
    try {
      for (int i = 0; i < widget.user.savedAddresses.length; i++) {
        widget.user.savedAddresses[i].address = _addressControllers[i].text;
      }

      // Gọi qua lớp Service tách biệt để xử lý tầng Data/Network
      await _userService.updateUserProfile(
        userId: widget.user.id,
        fullname: _nameController.text,
        email: _emailController.text,
        addresses: widget.user.savedAddresses,
        avatarFile: _selectedAvatarFile,
      );

      setState(() {
        _isEditing = false;
        _selectedAvatarFile = null;
      });
      widget.onProfileUpdated(); // Gọi trigger reload dữ liệu
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDarkMode ? LuxeColors.cardDark : Colors.white;

    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? LuxeColors.bgDark
          : LuxeColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // --- HEADER PROFILE (Giữ lại cấu trúc gọn gàng) ---
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatarImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: LuxeColors.goldPrimary,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(42),
                                child: _selectedAvatarFile != null
                                    ? Image.file(
                                        _selectedAvatarFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : (widget.user.avatarUrl != null &&
                                          widget.user.avatarUrl!.isNotEmpty)
                                    ? Image.network(
                                        widget.user.avatarUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.person, size: 40),
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: LuxeColors.goldPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_isEditing) ...[
                      Text(
                        _nameController.text,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailController.text,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: _emailController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: LuxeColors.goldPrimary.withOpacity(0.1),
                            border: Border.all(
                              color: LuxeColors.goldPrimary.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.user.role.name} • ACTIVE',
                            style: const TextStyle(
                              color: LuxeColors.goldPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            _isEditing ? Icons.close : Icons.edit_outlined,
                            size: 16,
                          ),
                          onPressed: () => setState(() {
                            if (_isEditing) {
                              _initControllers();
                              _selectedAvatarFile = null;
                            }
                            _isEditing = !_isEditing;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SUB-WIDGET 1: DIGITAL CARD ---
              DigitalRewardCard(fullname: _nameController.text),
              const SizedBox(height: 20),

              // --- SUB-WIDGET 2: ACCORDION ADDRESS ---
              ProfileAccordionTile(
                leadingIcon: Icons.map_outlined,
                title:
                    'Saved Shipping Addresses (${widget.user.savedAddresses.length})',
                isOpen: _activeSection == 'address',
                isDarkMode: widget.isDarkMode,
                onTap: () => setState(
                  () => _activeSection = _activeSection == 'address'
                      ? null
                      : 'address',
                ),
                child: widget.user.savedAddresses.isEmpty
                    ? const Text(
                        'No addresses saved yet.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.user.savedAddresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = widget.user.savedAddresses[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _getAddressIcon(item.type),
                                color: LuxeColors.goldPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.type.name.toUpperCase()} LOCATION',
                                      style: const TextStyle(
                                        color: LuxeColors.goldPrimary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    if (!_isEditing)
                                      Text(
                                        item.address,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: TextField(
                                          controller:
                                              _addressControllers[index],
                                          style: const TextStyle(fontSize: 12),
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.all(8),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // --- SUB-WIDGET 3: ACCORDION PAYMENT ---
              ProfileAccordionTile(
                leadingIcon: Icons.credit_card_outlined,
                title: 'Saved Digital Wallet',
                isOpen: _activeSection == 'payment',
                isDarkMode: widget.isDarkMode,
                onTap: () => setState(
                  () => _activeSection = _activeSection == 'payment'
                      ? null
                      : 'payment',
                ),
                child: widget.user.savedPaymentMethods.isEmpty
                    ? const Text(
                        'No digital wallets linked.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.user.savedPaymentMethods.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final payment =
                              widget.user.savedPaymentMethods[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.isDarkMode
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.credit_card,
                                      color: LuxeColors.goldPrimary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      payment.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  payment.last4 != null
                                      ? '•••• ${payment.last4}'
                                      : 'QuickPay',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // --- BUTTON: CLOUD SAVE ---
              if (_isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LuxeColors.goldPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving ? null : _handleSaveChanges,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.cloud_upload_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                    label: const Text(
                      'SAVE CLOUD CHANGES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // --- DARK MODE SWITCH & LOGOUT BUTTON (Giữ nguyên) ---
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.dark_mode_outlined,
                          color: LuxeColors.goldPrimary,
                          size: 18,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aroma Premium Dark Theme',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Eye-safe, roasted blacks & dynamic gold aesthetics',
                              style: TextStyle(color: Colors.grey, fontSize: 9),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: widget.isDarkMode,
                      activeColor: LuxeColors.goldPrimary,
                      onChanged: (_) => widget.onToggleDarkMode(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout, color: Colors.red, size: 16),
                  label: const Text(
                    'CLOSE SESSION',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
