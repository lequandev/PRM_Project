# 🔥 FIRESTORE SCHEMA — Coffee Shop Project
## Database Contract (thay thế OpenAPI Spec cho Firebase)

> **Phiên bản:** 1.0 | **Ngày tạo:** 16/07/2026  
> **Owner:** Dev 1 — Chỉ Dev 1 được thay đổi file này  
> **Quan trọng:** Đây là **nguồn sự thật duy nhất** cho cấu trúc database.  
> Tất cả Dev đọc file này trước khi đọc/ghi Firestore.

---

## 📌 Quy ước chung

| Ký hiệu | Ý nghĩa |
|---|---|
| `Collection` | Tập hợp documents (in đậm) |
| `{id}` | Document ID (dynamic) |
| `→` | Subcollection |
| `?` | Field optional (nullable) |
| `TS` | Firestore Timestamp |
| `Ref` | DocumentReference (foreign key) |

**Document ID convention:**
- Users: Firebase Auth UID (`uid`)
- Tất cả còn lại: Firestore auto-generated ID

---

## 1. 👤 Collection: `users`

```
/users/{uid}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `uid` | `String` | ✅ | Firebase Auth UID |
| `email` | `String` | ✅ | Email đăng nhập |
| `name` | `String` | ✅ | Tên hiển thị |
| `role` | `String` | ✅ | `'customer'` \| `'staff'` \| `'admin'` |
| `phone` | `String?` | ❌ | Số điện thoại |
| `avatarUrl` | `String?` | ❌ | URL ảnh từ Firebase Storage |
| `loyaltyPoints` | `int` | ✅ | Điểm tích lũy (default: 0) |
| `isActive` | `bool` | ✅ | Tài khoản bị ban = false |
| `createdAt` | `TS` | ✅ | Thời điểm tạo tài khoản |
| `updatedAt` | `TS` | ✅ | Thời điểm cập nhật cuối |

### Subcollection: `/users/{uid}/addresses`
```
/users/{uid}/addresses/{addressId}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `id` | `String` | ✅ | Auto ID |
| `label` | `String` | ✅ | `'Nhà'` \| `'Cơ quan'` \| custom |
| `street` | `String` | ✅ | Số nhà + tên đường |
| `ward` | `String` | ✅ | Phường/Xã |
| `district` | `String` | ✅ | Quận/Huyện |
| `city` | `String` | ✅ | Thành phố |
| `isDefault` | `bool` | ✅ | Địa chỉ mặc định |
| `lat` | `double?` | ❌ | Latitude (Google Maps) |
| `lng` | `double?` | ❌ | Longitude (Google Maps) |

### Subcollection: `/users/{uid}/loyaltyTransactions`
```
/users/{uid}/loyaltyTransactions/{txId}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `id` | `String` | ✅ | Auto ID |
| `type` | `String` | ✅ | `'earn'` \| `'redeem'` |
| `points` | `int` | ✅ | Số điểm (+ hoặc -) |
| `orderId` | `String?` | ❌ | Ref tới `/orders/{orderId}` |
| `description` | `String` | ✅ | Mô tả giao dịch |
| `createdAt` | `TS` | ✅ | Thời điểm giao dịch |

---

## 2. 📂 Collection: `categories`

```
/categories/{categoryId}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `id` | `String` | ✅ | Auto ID |
| `name` | `String` | ✅ | Tên danh mục (vd: "Cà phê", "Trà sữa") |
| `imageUrl` | `String?` | ❌ | URL ảnh từ Firebase Storage |
| `displayOrder` | `int` | ✅ | Thứ tự hiển thị |
| `isActive` | `bool` | ✅ | Hiển thị hay ẩn |
| `createdAt` | `TS` | ✅ | |

---

## 3. ☕ Collection: `products`

```
/products/{productId}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `id` | `String` | ✅ | Auto ID |
| `name` | `String` | ✅ | Tên sản phẩm |
| `description` | `String?` | ❌ | Mô tả sản phẩm |
| `categoryId` | `String` | ✅ | Ref tới `/categories/{id}` |
| `basePrice` | `double` | ✅ | Giá cơ bản (VND) |
| `imageUrl` | `String?` | ❌ | URL ảnh |
| `isAvailable` | `bool` | ✅ | Còn phục vụ hay không |
| `isArchived` | `bool` | ✅ | Đã xóa mềm (UC-33) |
| `tags` | `List<String>` | ✅ | vd: `['bestseller', 'new', 'hot']` |
| `avgRating` | `double` | ✅ | Điểm đánh giá trung bình (0.0–5.0) |
| `totalReviews` | `int` | ✅ | Tổng số lượt đánh giá |
| `createdAt` | `TS` | ✅ | |
| `updatedAt` | `TS` | ✅ | |

### Subcollection: `/products/{productId}/customizations`
```
/products/{productId}/customizations/{customizationId}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `id` | `String` | ✅ | Auto ID |
| `type` | `String` | ✅ | `'size'` \| `'ice'` \| `'sugar'` \| `'milk'` |
| `label` | `String` | ✅ | Tên hiển thị (vd: "Kích thước") |
| `choices` | `List<CustomizationChoice>` | ✅ | Danh sách lựa chọn (xem bên dưới) |
| `isRequired` | `bool` | ✅ | Bắt buộc chọn hay không |

**CustomizationChoice (nested object trong choices):**
```json
{
  "value": "large",
  "label": "Lớn (L)",
  "extraPrice": 5000.0
}
```

### Subcollection: `/products/{productId}/reviews`
```
/products/{productId}/reviews/{reviewId}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `id` | `String` | ✅ | Auto ID |
| `userId` | `String` | ✅ | UID của customer |
| `userName` | `String` | ✅ | Tên hiển thị (snapshot) |
| `rating` | `int` | ✅ | 1–5 sao |
| `comment` | `String?` | ❌ | Nội dung đánh giá |
| `status` | `String` | ✅ | `'pending'` \| `'approved'` \| `'rejected'` |
| `orderId` | `String` | ✅ | Ref — chỉ mua rồi mới review |
| `createdAt` | `TS` | ✅ | |

---

## 4. 📋 Collection: `orders`

```
/orders/{orderId}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `id` | `String` | ✅ | Auto ID |
| `customerId` | `String` | ✅ | UID của customer |
| `customerName` | `String` | ✅ | Snapshot tên |
| `customerPhone` | `String?` | ❌ | Snapshot SĐT |
| `items` | `List<OrderItem>` | ✅ | Danh sách sản phẩm (xem bên dưới) |
| `subtotal` | `double` | ✅ | Tổng trước giảm giá |
| `discountAmount` | `double` | ✅ | Số tiền giảm (default: 0) |
| `totalAmount` | `double` | ✅ | Thực trả |
| `status` | `String` | ✅ | Xem bảng status bên dưới |
| `orderType` | `String` | ✅ | `'pickup'` \| `'delivery'` |
| `deliveryAddress` | `Map?` | ❌ | Snapshot địa chỉ giao hàng |
| `voucherCode` | `String?` | ❌ | Mã voucher đã dùng |
| `paymentMethod` | `String` | ✅ | `'cash'` \| `'vnpay'` \| `'momo'` \| `'zalopay'` |
| `paymentStatus` | `String` | ✅ | `'pending'` \| `'paid'` \| `'refunded'` |
| `note` | `String?` | ❌ | Ghi chú của khách |
| `cancelReason` | `String?` | ❌ | Lý do hủy (nếu bị hủy) |
| `loyaltyPointsEarned` | `int` | ✅ | Điểm tích lũy được (default: 0) |
| `loyaltyPointsUsed` | `int` | ✅ | Điểm đã dùng để đổi (default: 0) |
| `createdAt` | `TS` | ✅ | |
| `updatedAt` | `TS` | ✅ | |
| `acceptedAt` | `TS?` | ❌ | Khi staff chấp nhận |
| `readyAt` | `TS?` | ❌ | Khi sẵn sàng lấy |
| `deliveredAt` | `TS?` | ❌ | Khi giao xong |

**OrderStatus values:**
| Value | Mô tả | UC |
|---|---|---|
| `pending` | Chờ staff xác nhận | UC-17 |
| `accepted` | Staff đã chấp nhận | UC-21 |
| `preparing` | Đang pha chế | UC-22 |
| `ready` | Sẵn sàng lấy hàng | UC-23 |
| `delivered` | Đã giao/nhận | UC-24 |
| `cancelled` | Đã hủy | UC-26 |

**OrderItem (nested object trong items):**
```json
{
  "productId": "abc123",
  "productName": "Cà phê sữa đá",
  "productImageUrl": "https://...",
  "quantity": 2,
  "unitPrice": 35000.0,
  "totalPrice": 70000.0,
  "customizations": {
    "size": "large",
    "ice": "50%",
    "sugar": "70%",
    "milk": "oat"
  },
  "note": "Ít đường hơn"
}
```

---

## 5. 🎟️ Collection: `vouchers`

```
/vouchers/{voucherCode}
```
> Document ID = voucher code (vd: `COFFEE20`, `FREESHIP`)

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `code` | `String` | ✅ | Mã giảm giá (= document ID) |
| `description` | `String` | ✅ | Mô tả chương trình |
| `discountType` | `String` | ✅ | `'percentage'` \| `'fixed'` |
| `discountValue` | `double` | ✅ | % hoặc số tiền VND |
| `maxDiscountAmount` | `double?` | ❌ | Trần giảm tối đa (cho loại %) |
| `minOrderValue` | `double` | ✅ | Đơn tối thiểu (default: 0) |
| `usageLimit` | `int?` | ❌ | Giới hạn lượt dùng tổng |
| `usageCount` | `int` | ✅ | Đã dùng bao nhiêu lần |
| `perUserLimit` | `int` | ✅ | Giới hạn mỗi user (default: 1) |
| `isActive` | `bool` | ✅ | Còn hiệu lực |
| `startDate` | `TS` | ✅ | Ngày bắt đầu |
| `expiresAt` | `TS` | ✅ | Ngày hết hạn |
| `createdBy` | `String` | ✅ | Admin UID |
| `createdAt` | `TS` | ✅ | |

---

## 6. 📦 Collection: `inventory`

```
/inventory/{ingredientId}
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `id` | `String` | ✅ | Auto ID |
| `name` | `String` | ✅ | Tên nguyên liệu |
| `unit` | `String` | ✅ | Đơn vị: `'kg'` \| `'lít'` \| `'hộp'` \| `'cái'` |
| `currentStock` | `double` | ✅ | Số lượng hiện tại |
| `minStock` | `double` | ✅ | Ngưỡng cảnh báo hết |
| `status` | `String` | ✅ | `'available'` \| `'low'` \| `'out_of_stock'` |
| `updatedAt` | `TS` | ✅ | |
| `updatedBy` | `String` | ✅ | UID người cập nhật |

---

## 7. 🏪 Document: `store_config` (singleton)

```
/config/store   ← Collection: config, Document ID: store
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `storeName` | `String` | ✅ | Tên cửa hàng |
| `address` | `String` | ✅ | Địa chỉ cửa hàng |
| `phone` | `String` | ✅ | Số điện thoại |
| `openTime` | `String` | ✅ | vd: `"07:00"` |
| `closeTime` | `String` | ✅ | vd: `"22:00"` |
| `isOpen` | `bool` | ✅ | Quán đang mở hay đóng |
| `deliveryFee` | `double` | ✅ | Phí giao hàng mặc định |
| `minDeliveryOrder` | `double` | ✅ | Đơn tối thiểu để giao |
| `loyaltyRate` | `double` | ✅ | Tỷ lệ tích điểm (vd: 0.01 = 1đ/100đ) |
| `updatedAt` | `TS` | ✅ | |

---

## 8. 🔒 Firestore Security Rules (Draft)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuth() {
      return request.auth != null;
    }
    function isOwner(uid) {
      return request.auth.uid == uid;
    }
    function getRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    function isCustomer() { return getRole() == 'customer'; }
    function isStaff()    { return getRole() == 'staff'; }
    function isAdmin()    { return getRole() == 'admin'; }

    // Users
    match /users/{uid} {
      allow read:  if isAuth() && (isOwner(uid) || isAdmin());
      allow create: if isAuth() && isOwner(uid);
      allow update: if isAuth() && (isOwner(uid) || isAdmin());
      allow delete: if isAdmin();

      match /addresses/{addressId} {
        allow read, write: if isAuth() && isOwner(uid);
      }
      match /loyaltyTransactions/{txId} {
        allow read:  if isAuth() && (isOwner(uid) || isAdmin());
        allow write: if false; // Only via Cloud Functions
      }
    }

    // Categories
    match /categories/{categoryId} {
      allow read:  if true;               // Public
      allow write: if isAuth() && isAdmin();
    }

    // Products
    match /products/{productId} {
      allow read:  if true;               // Public
      allow write: if isAuth() && isAdmin();

      match /customizations/{id} {
        allow read:  if true;
        allow write: if isAuth() && isAdmin();
      }
      match /reviews/{reviewId} {
        allow read:  if true;
        allow create: if isAuth() && isCustomer();
        allow update: if isAuth() && isAdmin(); // moderation
        allow delete: if isAuth() && isAdmin();
      }
    }

    // Orders
    match /orders/{orderId} {
      allow read:  if isAuth() && (
        resource.data.customerId == request.auth.uid || isStaff() || isAdmin()
      );
      allow create: if isAuth() && isCustomer();
      allow update: if isAuth() && (isStaff() || isAdmin() ||
        // Customer chỉ được cancel khi status = pending
        (isCustomer() && resource.data.customerId == request.auth.uid
          && resource.data.status == 'pending')
      );
      allow delete: if false; // Orders không bao giờ xóa
    }

    // Vouchers
    match /vouchers/{code} {
      allow read:  if isAuth();
      allow write: if isAuth() && isAdmin();
    }

    // Inventory
    match /inventory/{ingredientId} {
      allow read:  if isAuth() && (isStaff() || isAdmin());
      allow write: if isAuth() && (isStaff() || isAdmin());
    }

    // Store Config
    match /config/{docId} {
      allow read:  if true;              // Public (isOpen, openTime...)
      allow write: if isAuth() && isAdmin();
    }
  }
}
```

---

## 9. 📊 Collection Map — Quick Reference

```
Firestore
├── users/
│   └── {uid}/
│       ├── addresses/
│       └── loyaltyTransactions/
├── categories/
├── products/
│   └── {productId}/
│       ├── customizations/
│       └── reviews/
├── orders/
├── vouchers/
├── inventory/
└── config/
    └── store   ← singleton document
```

---

*File này là API Contract chính thức của dự án. Mọi thay đổi schema phải được Dev 1 approve và cập nhật vào đây.*  
*Sau mỗi thay đổi, thông báo toàn team trong Daily Standup.*
