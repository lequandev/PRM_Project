# ☕ coffee_shop_core

> **Owner:** Dev 1 — Leader  
> **Version:** 1.0.0  
> Flutter package dùng chung cho toàn dự án Coffee Shop.  
> **TUYỆT ĐỐI không sửa file trong package này nếu không phải Dev 1.**

---

## 📦 Cài đặt vào app của bạn

Trong `pubspec.yaml` của `app_customer`, `app_staff`, `app_admin`:

```yaml
dependencies:
  coffee_shop_core:
    path: ../core_module
```

Import duy nhất cần dùng:

```dart
import 'package:coffee_shop_core/coffee_shop_core.dart';
```

---

## 🗂️ Cấu trúc

```
lib/
├── coffee_shop_core.dart          ← Barrel export (import cái này là đủ)
└── src/
    ├── models/
    │   ├── common/app_exception.dart
    │   ├── user/user_model.dart
    │   ├── user/address_model.dart
    │   ├── user/loyalty_transaction_model.dart
    │   ├── product/product_model.dart
    │   ├── product/category_model.dart
    │   ├── product/customization_model.dart
    │   ├── product/review_model.dart
    │   ├── order/order_model.dart
    │   ├── order/order_item_model.dart
    │   ├── order/order_status.dart      ← Enums: OrderStatus, UserRole...
    │   ├── voucher/voucher_model.dart
    │   └── inventory/ingredient_model.dart
    ├── services/
    │   ├── auth_service.dart            ← ✅ FULLY IMPLEMENTED (Dev 1)
    │   ├── inventory_service.dart       ← ✅ FULLY IMPLEMENTED (Dev 1)
    │   ├── store_config_service.dart    ← ✅ FULLY IMPLEMENTED (Dev 1)
    │   ├── product_service.dart         ← 🔌 STUB — implemented on request
    │   ├── user_service.dart            ← 🔌 STUB — implemented on request
    │   ├── order_service.dart           ← 🔌 STUB — implemented on request
    │   ├── voucher_service.dart         ← 🔌 STUB — implemented on request
    │   └── storage_service.dart         ← 🔧 UTILITY
    ├── theme/
    │   ├── app_colors.dart
    │   ├── app_typography.dart
    │   ├── app_spacing.dart
    │   └── app_theme.dart
    └── utils/
        ├── extensions/string_extensions.dart
        ├── extensions/datetime_extensions.dart
        ├── extensions/num_extensions.dart
        ├── validators/form_validators.dart
        └── helpers/logger.dart
```

---

## 🔐 AuthService (UC-01, UC-02, UC-03)

```dart
final auth = AuthService();

// UC-01: Đăng ký
final user = await auth.registerCustomer(
  email: 'user@email.com',
  password: 'Password1',
  name: 'Nguyễn Văn A',
  phone: '0912345678',
);

// UC-02: Đăng nhập — trả về user.role để navigate
final user = await auth.signIn(email: email, password: password);
switch (user.role) {
  case 'customer': // → app_customer
  case 'staff':    // → app_staff
  case 'admin':    // → app_admin
}

// UC-03: Quên mật khẩu
await auth.sendPasswordResetEmail('user@email.com');

// Stream đăng nhập — dùng trong Provider
auth.authStateChanges.listen((firebaseUser) { ... });
```

---

## 📦 InventoryService (UC-34)

```dart
final inventory = InventoryService();

// Lấy tất cả nguyên liệu
final ingredients = await inventory.getAllIngredients();

// Stream realtime cho dashboard
inventory.watchInventory().listen((list) { ... });

// Nguyên liệu sắp hết
final lowStock = await inventory.getLowStockIngredients();

// Cập nhật số lượng
await inventory.updateStock(
  ingredientId: 'abc123',
  newStock: 5.0,
  updatedBy: currentUser.uid,
);
```

---

## 🏪 StoreConfigService (UC-36)

```dart
final configService = StoreConfigService();

// Lấy config
final config = await configService.getStoreConfig();
print(config.isOpen);          // true/false
print(config.deliveryFee);     // 15000.0
print(config.loyaltyRate);     // 0.01

// Tính điểm loyalty
final points = config.calculateLoyaltyPoints(150000); // → 1

// Stream realtime
configService.watchStoreConfig().listen((config) { ... });

// Bật/tắt quán
await configService.toggleStoreOpen(false);
```

---

## 🎨 Theme

```dart
// Trong MaterialApp:
MaterialApp(
  theme: AppTheme.light,   // Customer & Staff app
  // hoặc
  theme: AppTheme.admin,   // Admin app
)

// Màu sắc
AppColors.primary         // Nâu cà phê
AppColors.statusPending   // Orange
AppColors.statusReady     // Green

// Typography
AppTypography.h1
AppTypography.bodyMedium
AppTypography.price

// Spacing
AppSpacing.md   // 16.0
AppRadius.card  // 12.0
```

---

## 🛠️ Utils

```dart
// String
'hello world'.titleCase     // 'Hello World'
'test@'.isValidEmail        // false
'cà phê'.withoutDiacritics  // 'ca phe' (dùng cho search)

// DateTime
DateTime.now().toVnDate     // '16/07/2026'
order.createdAt.timeAgo     // '5 phút trước'

// Number (VND)
35000.toVnd                 // '35.000đ'
1500.toPoints               // '1.500 điểm'

// Form validators
TextFormField(
  validator: FormValidators.email,
  validator: FormValidators.password,
)

// Logger
AppLogger.info('User logged in', tag: 'Auth');
AppLogger.error('Firestore failed', error: e);
```

---

## ⚠️ Quy tắc quan trọng

1. **Chỉ Dev 1** được sửa bất kỳ file nào trong `core_module`
2. Nếu cần thêm field vào Model → tạo **GitHub Issue** gán cho Dev 1
3. Nếu cần implement stub service → tạo **GitHub Issue** gán cho Dev 1
4. **KHÔNG** tự import `cloud_firestore` trực tiếp trong `app_customer/app_staff/app_admin`  
   — luôn dùng service từ `core_module`

---

## 🔄 Tạo code (build_runner)

```bash
# Chạy trong thư mục core_module/
cd core_module
dart run build_runner build --delete-conflicting-outputs
```

Lệnh này sẽ tạo ra các file `.freezed.dart` và `.g.dart` cho tất cả models.

---

*core_module v1.0.0 — Dev 1 | Coffee Shop Project | 16/07/2026*
