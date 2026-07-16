# ⚙️ TECH STACK — Coffee Shop Flutter Project

> **Phiên bản:** 1.0 | **Ngày xác nhận:** 16/07/2026  
> **Người xác nhận:** Dev 1 (Leader)  
> **Trạng thái:** ✅ CONFIRMED — Không thay đổi nếu không có sự đồng ý của cả nhóm

---

## 1. 🏗️ Kiến trúc tổng thể

| Quyết định | Lựa chọn |
|---|---|
| Cấu trúc repo | **Monorepo — Multi-Package** (theo V2 workflow) |
| Flutter SDK | `>=3.12.0` |

```text
coffee_shop_project/          ← Git root
├── core_module/              ← Flutter Package  (Dev 1 owns)
├── app_customer/             ← Flutter App      (Dev 2 + Dev 3)
├── app_staff/                ← Flutter App      (Dev 4)
├── app_admin/                ← Flutter App/Web  (Dev 5)
├── TECH_STACK.md             ← file này
└── FIRESTORE_SCHEMA.md       ← database contract
```

---

## 2. 🔥 Backend — Firebase

| Service | Dùng cho |
|---|---|
| **Firebase Auth** | Xác thực tất cả actors (Customer / Staff / Admin) |
| **Cloud Firestore** | Toàn bộ database (real-time, offline support) |
| **Firebase Storage** | Upload ảnh sản phẩm, avatar người dùng |
| **Firebase Cloud Messaging (FCM)** | Push notifications (UC-30) |

> **Môi trường:**
> - `dev` — Firebase project: `coffee-shop-dev`
> - `prod` — Firebase project: `coffee-shop-prod`  
> Config mỗi môi trường lưu trong `lib/config/` (không commit lên Git — xem `.gitignore`)

---

## 3. 📦 State Management

| Package | Phiên bản | Ghi chú |
|---|---|---|
| **provider** | `^6.1.0` | State management chính cho tất cả apps |
| **ChangeNotifier** | (built-in) | Base class cho tất cả Providers |

**Quy ước đặt tên Provider:**
```dart
// Đặt tên: <FeatureName>Provider
class AuthProvider extends ChangeNotifier { ... }
class CartProvider extends ChangeNotifier { ... }
class OrderProvider extends ChangeNotifier { ... }
```

---

## 4. 📚 Thư viện toàn dự án (core_module)

### Models & Serialization
| Package | Phiên bản | Mục đích |
|---|---|---|
| `freezed_annotation` | `^2.4.0` | Immutable model classes |
| `json_annotation` | `^4.9.0` | JSON serialization |
| `freezed` *(dev)* | `^2.5.0` | Code generator cho freezed |
| `json_serializable` *(dev)* | `^6.8.0` | Code generator cho JSON |
| `build_runner` *(dev)* | `^2.4.0` | Chạy code generation |

### Firebase
| Package | Phiên bản | Mục đích |
|---|---|---|
| `firebase_core` | `^3.0.0` | Firebase initialization |
| `firebase_auth` | `^5.0.0` | Authentication |
| `cloud_firestore` | `^5.0.0` | Database |
| `firebase_storage` | `^12.0.0` | File storage |
| `firebase_messaging` | `^15.0.0` | Push notifications (UCe-30) |

### Navigation
| Package | Phiên bản | Mục đích |
|---|---|---|
| `go_router` | `^14.0.0` | Declarative routing + deep links |

### UI & UX
| Package | Phiên bản | Mục đích |
|---|---|---|
| `cached_network_image` | `^3.4.0` | Cache ảnh từ Firebase Storage |
| `image_picker` | `^1.2.3` | Chọn ảnh từ gallery/camera |
| `flutter_svg` | `^2.0.0` | SVG icon support |

### Utilities
| Package | Phiên bản | Mục đích |
|---|---|---|
| `shared_preferences` | `^2.5.5` | Lưu trữ nhẹ local (theme, language) |
| `flutter_secure_storage` | `^9.2.2` | Lưu token bảo mật |
| `intl` | `^0.19.0` | Format tiền tệ VND, ngày giờ |
| `equatable` | `^2.0.7` | So sánh objects |
| `uuid` | `^4.5.0` | Generate unique IDs client-side |

---

## 5. 🔐 Auth — RBAC (Role-Based Access Control)

Firebase Auth + Custom Claims:

```
Role: 'customer'  → app_customer
Role: 'staff'     → app_staff  
Role: 'admin'     → app_admin
```

**Flow:**
1. User đăng nhập → Firebase Auth trả về `UserCredential`
2. Đọc Firestore `/users/{uid}` → lấy field `role`
3. Navigate đến đúng app/screen dựa trên role
4. Firestore Security Rules enforce permissions server-side

---

## 6. 📐 Code Conventions

| Item | Convention |
|---|---|
| File naming | `snake_case.dart` |
| Class naming | `PascalCase` |
| Variable/method | `camelCase` |
| Constants | `kConstantName` hoặc `SCREAMING_SNAKE` |
| Provider files | `<feature>_provider.dart` |
| Screen files | `<feature>_screen.dart` |
| Widget files | `<feature>_widget.dart` hoặc `<name>_card.dart` |

---

## 7. 🚦 Quy tắc dependency

```
app_customer ──┐
app_staff    ──┼──► core_module ──► Firebase
app_admin    ──┘
```

- Apps **KHÔNG** import lẫn nhau
- Tất cả đều import từ `core_module`
- `core_module` **KHÔNG** import từ bất kỳ app nào

---

*Mọi thay đổi tech stack phải được Dev 1 approve và cập nhật file này.*
