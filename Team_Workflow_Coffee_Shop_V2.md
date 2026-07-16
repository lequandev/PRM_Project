# ☕ CONTEXT PROMPT — Coffee Shop Flutter Project (5-Person Team)

> **Phiên bản:** V2.0 | **Ngày cập nhật:** 15/07/2026
> **Mục đích:** Đây là file **System Context** dùng chung khi ra lệnh cho AI (Cursor, Copilot, ChatGPT, Gemini). Mỗi thành viên **PHẢI** paste nội dung file này vào đầu mỗi session AI để tránh conflict và đảm bảo AI không tự ý sửa code ngoài phạm vi phân công.

---

## 1. 🏗 KIẾN TRÚC DỰ ÁN (PROJECT STRUCTURE)

Dự án áp dụng kiến trúc **Multi-package / Feature-First** để 5 người không bị conflict file.

```text
/coffee_shop_project
│
├── /core_module              ← Dev 1 SỞ HỮU (Models, API Client, Theme, Utils, Auth)
│   ├── /models               ← Toàn bộ Dart models (freezed / json_serializable)
│   ├── /network              ← API Client, interceptors, error handling
│   ├── /theme                ← AppTheme, colors, typography
│   └── /utils                ← Extensions, helpers, validators dùng chung
│
├── /app_customer             ← Dev 2 & Dev 3 làm việc
│   └── /lib/features/
│       ├── /auth             ← (dùng từ core, không tự viết)
│       ├── /menu             ← Dev 2: UC-07 đến UC-12
│       ├── /cart             ← Dev 2: UC-11, UC-12
│       ├── /checkout         ← Dev 3: UC-13 đến UC-17
│       ├── /orders           ← Dev 3: UC-18, UC-19, UC-27, UC-28, UC-39
│       └── /profile          ← Dev 3: UC-03, UC-04, UC-05, UC-06
│
├── /app_staff                ← Dev 4 SỞ HỮU hoàn toàn
│   └── /lib/features/
│       └── /orders           ← Dev 4: UC-20 đến UC-26
│
└── /app_admin                ← Dev 5 SỞ HỮU hoàn toàn
    └── /lib/features/
        ├── /menu_management  ← Dev 5: UC-31, UC-32, UC-33
        ├── /inventory        ← Dev 5: UC-34, UC-35, UC-36
        ├── /marketing        ← Dev 5: UC-29, UC-30
        └── /analytics        ← Dev 5: UC-37, UC-38, UC-40
```

> ⚠️ **QUY TẮC SỐ 1 — TUYỆT ĐỐI:** Chỉ **Dev 1** được sửa file trong `/core_module`. Nếu cần thêm field vào Model, tạo GitHub Issue gán cho Dev 1, **không tự sửa**.

---

## 2. 📋 DANH SÁCH ĐẦY ĐỦ 40 USE CASE

### Module 1: Xác thực & Quản lý hồ sơ (UC-01 → UC-06)
| UC | Tên | Actor | Dev phụ trách |
|---|---|---|---|
| UC-01 | Đăng ký tài khoản mới | Customer | Dev 1 (API) + Dev 2 (UI) |
| UC-02 | Đăng nhập (RBAC) | All Actors | Dev 1 |
| UC-03 | Đặt lại mật khẩu (OTP/Email) | All Actors | Dev 1 (API) + Dev 3 (UI) |
| UC-04 | Xem & chỉnh sửa hồ sơ | All Actors | Dev 3 |
| UC-05 | Quản lý địa chỉ đã lưu | Customer | Dev 3 |
| UC-06 | Xóa tài khoản (GDPR) | Customer | Dev 3 |

### Module 2: Duyệt menu & Tùy chỉnh (UC-07 → UC-12)
| UC | Tên | Actor | Dev phụ trách |
|---|---|---|---|
| UC-07 | Duyệt danh mục menu | Customer | Dev 2 |
| UC-08 | Tìm kiếm & lọc sản phẩm | Customer | Dev 2 |
| UC-09 | Xem chi tiết sản phẩm | Customer | Dev 2 |
| UC-10 | Tùy chỉnh đồ uống (size, đá, đường, sữa) | Customer | Dev 2 |
| UC-11 | Thêm sản phẩm vào giỏ hàng | Customer | Dev 2 |
| UC-12 | Xem & chỉnh sửa giỏ hàng | Customer | Dev 2 |

### Module 3: Đặt hàng & Thanh toán (UC-13 → UC-19)
| UC | Tên | Actor | Dev phụ trách |
|---|---|---|---|
| UC-13 | Chọn loại đơn hàng (mang về / giao hàng) | Customer | Dev 3 |
| UC-14 | Áp dụng mã giảm giá / voucher | Customer | Dev 3 |
| UC-15 | Chọn phương thức thanh toán | Customer | Dev 3 |
| UC-16 | Xử lý thanh toán số (VNPay, MoMo, v.v.) | Customer | Dev 3 |
| UC-17 | Đặt hàng xác nhận | Customer | Dev 3 |
| UC-18 | Xem lịch sử đơn hàng | Customer | Dev 3 |
| UC-19 | Theo dõi trạng thái đơn theo thời gian thực | Customer | Dev 3 |

### Module 4: Vận hành quán & Xử lý đơn hàng (UC-20 → UC-26)
| UC | Tên | Actor | Dev phụ trách |
|---|---|---|---|
| UC-20 | Xem hàng đợi đơn hàng đến | Staff | Dev 4 |
| UC-21 | Chấp nhận / Từ chối đơn | Staff | Dev 4 |
| UC-22 | Cập nhật trạng thái "Đang pha chế" | Staff | Dev 4 |
| UC-23 | Cập nhật trạng thái "Sẵn sàng lấy hàng" | Staff | Dev 4 |
| UC-24 | Xác nhận bàn giao đơn / Giao hàng | Staff | Dev 4 |
| UC-25 | In hóa đơn | Staff | Dev 4 |
| UC-26 | Hủy đơn đang hoạt động kèm lý do | Staff | Dev 4 |

### Module 5: Loyalty & Marketing (UC-27 → UC-30)
| UC | Tên | Actor | Dev phụ trách |
|---|---|---|---|
| UC-27 | Tích & xem điểm loyalty | Customer | Dev 3 |
| UC-28 | Đổi điểm lấy phần thưởng | Customer | Dev 3 |
| UC-29 | Tạo & quản lý Voucher | Admin | Dev 5 |
| UC-30 | Gửi Push Notification | Admin | Dev 5 |

### Module 6: Quản lý Catalog & Kho (UC-31 → UC-36)
| UC | Tên | Actor | Dev phụ trách |
|---|---|---|---|
| UC-31 | Tạo sản phẩm menu mới | Admin | Dev 5 |
| UC-32 | Cập nhật chi tiết sản phẩm | Admin | Dev 5 |
| UC-33 | Xóa / Archive sản phẩm | Admin | Dev 5 |
| UC-34 | Theo dõi tồn kho nguyên liệu | Admin | Dev 1 (API) + Dev 5 (UI) |
| UC-35 | Cập nhật trạng thái kho / Đánh dấu hết hàng | Admin/Staff | Dev 4 (Staff UI) + Dev 5 (Admin UI) |
| UC-36 | Quản lý cấu hình cửa hàng | Admin | Dev 1 (API) + Dev 5 (UI) |

### Module 7: Báo cáo, Phân tích & Kiểm duyệt (UC-37 → UC-40)
| UC | Tên | Actor | Dev phụ trách |
|---|---|---|---|
| UC-37 | Tạo báo cáo doanh thu | Admin | Dev 5 |
| UC-38 | Xem phân tích sản phẩm bán chạy | Admin | Dev 5 |
| UC-39 | Gửi đánh giá & xếp hạng sản phẩm | Customer | Dev 3 |
| UC-40 | Kiểm duyệt đánh giá & phản hồi | Admin | Dev 5 |

---

## 3. 👥 PHÂN CÔNG CHI TIẾT 5 THÀNH VIÊN

### 👑 Dev 1 — Core, Backend & Architecture (Leader)
- **Phụ trách:** Database design, REST API, toàn bộ Dart Core Models (`freezed` / `json_serializable`)
- **Use Cases:** UC-01, UC-02, UC-03 (backend), UC-34 (backend), UC-36 (backend)
- **Thư mục:** `/core_module` + Backend server
- **Quyền đặc biệt:** **Người duy nhất** được commit vào `/core_module`. Tất cả thay đổi Model đi qua Dev 1.

### 📱 Dev 2 — Customer App: Khám phá & Giỏ hàng
- **Phụ trách:** Toàn bộ UI/UX từ lúc mở app đến khi bấm "Đặt hàng"
- **Use Cases:** UC-07, UC-08, UC-09, UC-10, UC-11, UC-12 (và UI đăng ký UC-01)
- **Thư mục:** `/app_customer/lib/features/menu` và `/app_customer/lib/features/cart`
- **Giao tiếp:** Expose `CartProvider` / `CartBloc` (interface thống nhất) để Dev 3 consume

### 💳 Dev 3 — Customer App: Thanh toán & Hậu mãi
- **Phụ trách:** Nhận data từ Cart của Dev 2, xử lý checkout, tracking và loyalty
- **Use Cases:** UC-03 (UI), UC-04, UC-05, UC-06, UC-13, UC-14, UC-15, UC-16, UC-17, UC-18, UC-19, UC-27, UC-28, UC-39
- **Thư mục:** `/app_customer/lib/features/checkout`, `/app_customer/lib/features/orders`, `/app_customer/lib/features/profile`
- **Dependency:** Đọc state từ `CartProvider` của Dev 2, **không sửa** file cart

### 👨‍🍳 Dev 4 — Staff App (Barista / Thu ngân)
- **Phụ trách:** Toàn bộ app nội bộ cho nhân viên
- **Use Cases:** UC-20, UC-21, UC-22, UC-23, UC-24, UC-25, UC-26, UC-35 (Staff UI)
- **Thư mục:** Toàn bộ `/app_staff`
- **Lưu ý:** Fetch order data qua API của Dev 1, không đụng code `/app_customer`

### 📈 Dev 5 — Admin App/Web (Chủ quán / Quản lý)
- **Phụ trách:** Dashboard quản trị, báo cáo, CRUD menu, kho hàng
- **Use Cases:** UC-29, UC-30, UC-31, UC-32, UC-33, UC-34 (UI), UC-35 (Admin UI), UC-36 (UI), UC-37, UC-38, UC-40
- **Thư mục:** Toàn bộ `/app_admin`
- **Lưu ý:** Target Flutter Web (desktop layout), không ảnh hưởng mobile apps

---

## 4. 🤖 PROMPT TEMPLATE CHO AI — COPY & PASTE KHI BẮT ĐẦU SESSION

> Thay thế `[...]` bằng thông tin thực tế của bạn trước khi dùng.

### ✅ Template Dev 1 (Leader / Core)
```
Bạn là Senior Flutter Developer & Backend Engineer.
Tôi là Dev 1 — Leader của dự án Coffee Shop gồm 5 người.

PHẠM VI CỦA TÔI:
- Thư mục: /core_module (Models, API Client, Theme, Utils) và Backend API
- Use Cases: UC-01 (API), UC-02, UC-03 (API), UC-34 (API), UC-36 (API)
- Tôi là NGƯỜI DUY NHẤT được sửa /core_module

STACK: Flutter + Dart, freezed, json_serializable, Dio, [tên backend]
NHIỆM VỤ HIỆN TẠI: [Mô tả nhiệm vụ cụ thể]

Chỉ viết code trong phạm vi của tôi. Nếu code cần thay đổi model, hãy ghi rõ để tôi review.
```

### ✅ Template Dev 2 (Customer - Menu & Cart)
```
Bạn là Senior Flutter Developer.
Tôi là Dev 2 trong dự án Coffee Shop 5 người.

PHẠM VI CỦA TÔI:
- Thư mục: /app_customer/lib/features/menu và /app_customer/lib/features/cart
- Use Cases: UC-07, UC-08, UC-09, UC-10, UC-11, UC-12

QUY TẮC BẮT BUỘC:
- CHỈ dùng Models từ /core_module, KHÔNG tự định nghĩa model mới
- KHÔNG sửa bất kỳ file nào trong /core_module
- KHÔNG chạm vào /features/checkout hay /features/orders (của Dev 3)
- Expose CartBloc/CartProvider theo interface đã thống nhất với Dev 3

STATE MANAGEMENT: [Riverpod / BLoC — điền vào]
NHIỆM VỤ HIỆN TẠI: [Mô tả nhiệm vụ cụ thể, ví dụ: UC-09 - Màn hình chi tiết sản phẩm]
```

### ✅ Template Dev 3 (Customer - Checkout & Post-Order)
```
Bạn là Senior Flutter Developer.
Tôi là Dev 3 trong dự án Coffee Shop 5 người.

PHẠM VI CỦA TÔI:
- Thư mục: /app_customer/lib/features/checkout, /features/orders, /features/profile
- Use Cases: UC-03(UI), UC-04, UC-05, UC-06, UC-13→UC-19, UC-27, UC-28, UC-39

QUY TẮC BẮT BUỘC:
- CHỈ đọc CartBloc/CartProvider của Dev 2, KHÔNG sửa file trong /features/cart
- CHỈ dùng Models từ /core_module, KHÔNG tự định nghĩa model mới
- KHÔNG sửa bất kỳ file nào trong /core_module

STATE MANAGEMENT: [Riverpod / BLoC — điền vào]
NHIỆM VỤ HIỆN TẠI: [Mô tả nhiệm vụ cụ thể]
```

### ✅ Template Dev 4 (Staff App)
```
Bạn là Senior Flutter Developer.
Tôi là Dev 4 trong dự án Coffee Shop 5 người.

PHẠM VI CỦA TÔI:
- Thư mục: /app_staff (TOÀN BỘ — tôi sở hữu hoàn toàn thư mục này)
- Use Cases: UC-20, UC-21, UC-22, UC-23, UC-24, UC-25, UC-26, UC-35 (Staff)

QUY TẮC BẮT BUỘC:
- CHỈ làm việc trong /app_staff
- KHÔNG chạm vào /app_customer, /app_admin, hoặc /core_module
- Fetch tất cả data qua API do Dev 1 cung cấp
- CHỈ dùng Models từ /core_module

STATE MANAGEMENT: [Riverpod / BLoC — điền vào]
NHIỆM VỤ HIỆN TẠI: [Mô tả nhiệm vụ cụ thể, ví dụ: UC-20 - Màn hình Order Queue]
```

### ✅ Template Dev 5 (Admin App/Web)
```
Bạn là Senior Flutter Developer (chuyên Flutter Web).
Tôi là Dev 5 trong dự án Coffee Shop 5 người.

PHẠM VI CỦA TÔI:
- Thư mục: /app_admin (TOÀN BỘ — tôi sở hữu hoàn toàn thư mục này)
- Target platform: Flutter Web (desktop layout, responsive)
- Use Cases: UC-29, UC-30, UC-31, UC-32, UC-33, UC-34(UI), UC-35(Admin), UC-36(UI), UC-37, UC-38, UC-40

QUY TẮC BẮT BUỘC:
- CHỈ làm việc trong /app_admin
- KHÔNG chạm vào /app_customer, /app_staff, hoặc /core_module
- CHỈ dùng Models từ /core_module, gọi API do Dev 1 cung cấp

STATE MANAGEMENT: [Riverpod / BLoC — điền vào]
NHIỆM VỤ HIỆN TẠI: [Mô tả nhiệm vụ cụ thể, ví dụ: UC-37 - Dashboard doanh thu]
```

---

## 5. 🔗 QUY TRÌNH GIT & XỬ LÝ CONFLICT

### Đặt tên branch (bắt buộc theo format)
```
feature/dev{số}-{tên-chức-năng}

Ví dụ:
  feature/dev2-product-detail-screen     ← UC-09
  feature/dev3-checkout-flow             ← UC-13→17
  feature/dev4-order-queue               ← UC-20
  feature/dev5-revenue-dashboard         ← UC-37
```

### Quy trình push code an toàn
```bash
# Bước 1: Cập nhật main mới nhất
git checkout main
git pull origin main

# Bước 2: Merge main vào branch của bạn
git checkout feature/dev{số}-{tên-chức-năng}
git merge main

# Bước 3: Resolve conflict THỦ CÔNG (không dùng AI để resolve conflict Git)
# AI không thể đảm bảo an toàn khi resolve conflict — luôn làm tay

# Bước 4: Push và tạo Pull Request
git push origin feature/dev{số}-{tên-chức-năng}
```

### Quy tắc Pull Request
- PR chỉ được merge khi đã được **ít nhất 1 người khác** review
- PR liên quan đến `/core_module` **bắt buộc** được Dev 1 approve
- Title PR: `[DevX][UC-XX] Tên chức năng`

---

## 6. 📅 LỊCH HỌP & GIAO TIẾP NHÓM

| Loại | Thời gian | Nội dung |
|---|---|---|
| **Daily Standup** | 15 phút mỗi sáng | Dev 1 thông báo thay đổi Core Model/API; mỗi Dev báo cáo tiến độ & blocker |
| **Interface Sync** | Khi Dev 2 expose Cart API | Dev 2 & Dev 3 họp xác nhận contract của CartBloc/Provider |
| **API Contract Review** | Trước khi Dev 2/3/4/5 bắt đầu consume API | Dev 1 chia sẻ Postman Collection / OpenAPI spec |
| **Weekly Demo** | Cuối tuần | Demo chức năng hoàn chỉnh, cả nhóm test chéo |

> 💡 **Tip:** Sau mỗi Daily Standup, nếu Dev 1 thông báo thay đổi Model, tất cả Dev còn lại phải **cập nhật lại Context Prompt** (phần Model snapshot bên dưới) trước khi tiếp tục ra lệnh AI.

---

## 7. 📦 CORE MODELS SNAPSHOT (Cập nhật bởi Dev 1)

> **Dev 1 cập nhật phần này sau mỗi khi thay đổi model. Các Dev khác copy phần này vào Prompt AI.**
> **Import:** `import 'package:coffee_shop_core/coffee_shop_core.dart';`

```dart
// ✅ Cập nhật lần cuối: 16/07/2026 — Dev 1 (core_module v1.0.0)
// Tất cả models dùng @freezed + fromFirestore() / toFirestore()

// ─── ENUMS ────────────────────────────────────────────────
enum OrderStatus { pending, accepted, preparing, ready, delivered, cancelled }
enum OrderType   { pickup, delivery }
enum PaymentMethod { cash, vnpay, momo, zalopay }
enum PaymentStatus { pending, paid, refunded }
enum UserRole    { customer, staff, admin }

// ─── USER ─────────────────────────────────────────────────
// Firestore: /users/{uid}
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;          // 'customer' | 'staff' | 'admin'
  final String? phone;
  final String? avatarUrl;
  final int loyaltyPoints;    // default: 0
  final bool isActive;        // false = banned
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

// Firestore: /users/{uid}/addresses/{addressId}
class AddressModel {
  final String id;
  final String label;         // 'Nhà' | 'Cơ quan' | custom
  final String street;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;
  final double? lat;
  final double? lng;
}

// Firestore: /users/{uid}/loyaltyTransactions/{txId}
class LoyaltyTransactionModel {
  final String id;
  final String type;          // 'earn' | 'redeem'
  final int points;
  final String description;
  final String? orderId;
  final DateTime? createdAt;
}

// ─── PRODUCT ──────────────────────────────────────────────
// Firestore: /categories/{categoryId}
class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int displayOrder;
  final bool isActive;
}

// Firestore: /products/{productId}
class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final double basePrice;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final bool isArchived;      // soft delete
  final List<String> tags;    // ['bestseller', 'new', 'hot']
  final double avgRating;
  final int totalReviews;
  final List<CustomizationModel> customizations;
}

// Firestore: /products/{id}/customizations/{id}
class CustomizationModel {
  final String id;
  final String type;          // 'size' | 'ice' | 'sugar' | 'milk'
  final String label;
  final List<CustomizationChoice> choices;
  final bool isRequired;
}

class CustomizationChoice {
  final String value;         // 'large'
  final String label;         // 'Lớn (L)'
  final double extraPrice;    // phụ thu thêm (VND)
}

// Firestore: /products/{id}/reviews/{reviewId}
class ReviewModel {
  final String id;
  final String userId;
  final String userName;      // snapshot
  final String orderId;       // bắt buộc đã mua
  final int rating;           // 1–5
  final String? comment;
  final String status;        // 'pending' | 'approved' | 'rejected'
}

// ─── ORDER ────────────────────────────────────────────────
// Firestore: /orders/{orderId}
class OrderModel {
  final String id;
  final String customerId;
  final String customerName;  // snapshot
  final String? customerPhone;
  final List<OrderItemModel> items;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final String status;        // OrderStatus enum
  final String orderType;     // 'pickup' | 'delivery'
  final Map<String, dynamic>? deliveryAddress;
  final String? voucherCode;
  final String paymentMethod; // 'cash' | 'vnpay' | 'momo' | 'zalopay'
  final String paymentStatus; // 'pending' | 'paid' | 'refunded'
  final String? note;
  final String? cancelReason;
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? readyAt;
  final DateTime? deliveredAt;
}

// nested trong orders[].items
class OrderItemModel {
  final String productId;
  final String productName;   // snapshot
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;     // giá TẠI THỜI ĐIỂM đặt
  final double totalPrice;    // unitPrice * quantity
  final Map<String, String> customizations; // {'size':'large','ice':'50%'}
  final String? note;
}

// ─── VOUCHER ──────────────────────────────────────────────
// Firestore: /vouchers/{voucherCode}  (document ID = mã code)
class VoucherModel {
  final String code;
  final String description;
  final String discountType;  // 'percentage' | 'fixed'
  final double discountValue;
  final double? maxDiscountAmount;
  final double minOrderValue;
  final int? usageLimit;
  final int usageCount;
  final int perUserLimit;
  final bool isActive;
  final DateTime startDate;
  final DateTime expiresAt;
}

// ─── INVENTORY ────────────────────────────────────────────
// Firestore: /inventory/{ingredientId}
class IngredientModel {
  final String id;
  final String name;
  final String unit;          // 'kg' | 'lít' | 'hộp' | 'cái'
  final double currentStock;
  final double minStock;      // ngưỡng cảnh báo
  final String status;        // 'available' | 'low' | 'out_of_stock'
  // Extension: computedStatus, isLow, isOutOfStock
}

// ─── STORE CONFIG ─────────────────────────────────────────
// Firestore: /config/store  (singleton document)
class StoreConfig {
  final String storeName;
  final String address;
  final String phone;
  final String openTime;      // '07:00'
  final String closeTime;     // '22:00'
  final bool isOpen;
  final double deliveryFee;
  final double minDeliveryOrder;
  final double loyaltyRate;   // 0.01 = 1 điểm/100đ
  // Method: calculateLoyaltyPoints(orderTotal)
}

// ─── EXCEPTIONS ───────────────────────────────────────────
class AppException { final String code; final String message; }
class AuthException extends AppException { /* invalidCredentials, emailAlreadyInUse... */ }
class DatabaseException extends AppException { /* notFound, permissionDenied... */ }
```

---

## 8. ⚡ QUICK REFERENCE — MA TRẬN UC VS DEV

| | Dev 1 | Dev 2 | Dev 3 | Dev 4 | Dev 5 |
|---|:---:|:---:|:---:|:---:|:---:|
| UC-01→02 | ✅ (API) | ✅ (UI) | | | |
| UC-03 | ✅ (API) | | ✅ (UI) | | |
| UC-04→06 | | | ✅ | | |
| UC-07→12 | | ✅ | | | |
| UC-13→19 | | | ✅ | | |
| UC-20→26 | | | | ✅ | |
| UC-27→28 | | | ✅ | | |
| UC-29→30 | | | | | ✅ |
| UC-31→33 | | | | | ✅ |
| UC-34 | ✅ (API) | | | | ✅ (UI) |
| UC-35 | | | | ✅ (Staff) | ✅ (Admin) |
| UC-36 | ✅ (API) | | | | ✅ (UI) |
| UC-37→38 | | | | | ✅ |
| UC-39 | | | ✅ | | |
| UC-40 | | | | | ✅ |

---

*File này được tạo từ cuộc trò chuyện phân tích dự án Coffee Shop (Flutter) ngày 15/07/2026.*
*Mọi cập nhật quan trọng phải được thông báo trong Daily Standup và cập nhật vào file này.*
