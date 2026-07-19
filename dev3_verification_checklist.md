# ☕ Dev 3 Verification Checklist (Customer App: Checkout, Orders & Profile)

This markdown checklist outlines the tasks, file structures, logic assessment, and verification steps for checking the completion of Dev 3's assignments.

---

## 📋 Task Mapping & Status

| Use Case | Description | Status | Implementation Code |
| :--- | :--- | :---: | :--- |
| **UC-03 (UI)** | Password Reset (Email/OTP) | ✅ Completed | [reset_password_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/screens/reset_password_screen.dart) |
| **UC-04** | View & Edit Profile | ✅ Completed | [profile_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/screens/profile_screen.dart)<br>[profile_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/providers/profile_provider.dart) |
| **UC-05** | Manage Saved Addresses | ✅ Completed | [addresses_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/screens/addresses_screen.dart)<br>[address_form_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/screens/address_form_screen.dart)<br>[address_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/providers/address_provider.dart) |
| **UC-06** | Delete Account (GDPR Compliance) | ✅ Completed | [profile_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/screens/profile_screen.dart) (`_startDeleteFlow`) |
| **UC-13** | Select Order Type (Pickup / Delivery) | ✅ Completed | [checkout_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/checkout/screens/checkout_screen.dart)<br>[checkout_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/checkout/providers/checkout_provider.dart) |
| **UC-14** | Apply Coupon / Voucher | ✅ Completed | [checkout_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/checkout/screens/checkout_screen.dart)<br>[checkout_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/checkout/providers/checkout_provider.dart) |
| **UC-15** | Select Payment Method | ✅ Completed | [payment_method_section.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/checkout/widgets/payment_method_section.dart) |
| **UC-16** | Digital Payment Integration (Demo) | ✅ Completed | [checkout_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/checkout/providers/checkout_provider.dart) (`placeOrder`) |
| **UC-17** | Confirm & Place Order | ✅ Completed | [checkout_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/checkout/screens/checkout_screen.dart)<br>[order_success_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/checkout/screens/order_success_screen.dart) |
| **UC-18** | Order History List | ✅ Completed | [order_history_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/orders/screens/order_history_screen.dart)<br>[order_history_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/orders/providers/order_history_provider.dart) |
| **UC-19** | Real-time Order Tracking | ✅ Completed | [order_tracking_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/orders/screens/order_tracking_screen.dart)<br>[order_tracking_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/orders/providers/order_tracking_provider.dart) |
| **UC-27** | View Loyalty Points & Transactions | ✅ Completed | [loyalty_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/screens/loyalty_screen.dart)<br>[loyalty_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/providers/loyalty_provider.dart) |
| **UC-28** | Redeem Points for Vouchers | ✅ Completed | [loyalty_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/screens/loyalty_screen.dart)<br>[loyalty_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/profile/providers/loyalty_provider.dart) (`redeemVoucher`) |
| **UC-39** | Product Review & Rating | ✅ Completed | [review_sheet.dart](file:///d:/Ky8/FinalPRM/prm_project/app_customer/lib/features/orders/widgets/review_sheet.dart) |

---

## 🛠️ File Structure Audit

Ensure that all files reside in the correct packages/features directories and respect boundaries (no editing of `/core_module` or `/features/cart` of Dev 2):

### 1. Checkout Feature (`/features/checkout`)
- **Screens:**
  - `checkout_screen.dart` (Full Checkout flow UI)
  - `order_success_screen.dart` (Success confirmation screen with Order ID)
- **Providers:**
  - `checkout_provider.dart` (Calculation, Voucher validation, Place Order command)
- **Widgets:**
  - `address_section.dart` (Select delivery address)
  - `payment_method_section.dart` (Choose payment methods)
  - `section_card.dart` (Shared container card UI for layout)

### 2. Orders Feature (`/features/orders`)
- **Screens:**
  - `order_history_screen.dart` (Filters history by Status, shows all user orders)
  - `order_tracking_screen.dart` (Real-time tracking of single order)
- **Providers:**
  - `order_history_provider.dart` (Fetch orders from repository, filter logic)
  - `order_tracking_provider.dart` (Stream subscription logic for status updates)
- **Widgets:**
  - `coffee_cup_progress.dart` (Dynamic brewing animation)
  - `pickup_hero_card.dart` (Horizontal stepper for Pickup orders)
  - `pickup_pass_sheet.dart` (Display pickup pass QR code)
  - `review_sheet.dart` (Rating slider and comment box)
  - `status_chip.dart` (Order status badge indicator)

### 3. Profile Feature (`/features/profile`)
- **Screens:**
  - `profile_screen.dart` (Main profile hub: edit sheet, address entry, reset password entry, delete account)
  - `addresses_screen.dart` (Manage and edit list of addresses)
  - `address_form_screen.dart` (Add/Edit address details)
  - `loyalty_screen.dart` (Points tracker, point conversion, history)
  - `reset_password_screen.dart` (OTP / Email password reset form)

---

## 🧪 Verification & Acceptance Criteria

### 🔒 Profile & GDPR (UC-03, UC-04, UC-05, UC-06)
- [ ] **UC-03:** Clicking "Reset Password" sends a mock/real password reset email to user and updates UI to confirmation state.
- [ ] **UC-04:** Changing profile fields (Name, Phone) saves correctly to profile model and reloads changes on Main Profile view.
- [ ] **UC-05:** Address List displays defaults correctly. Adding or updating address reloads the list without duplicate keys.
- [ ] **UC-06:** GDPR deletion flow requires entering "XOA" exactly, performs account deactivation, and redirects to initialization screen.

### 💳 Checkout Flow (UC-13, UC-14, UC-15, UC-16, UC-17)
- [ ] **UC-13:** Switching between "Delivery" and "Pickup" recalculates prices (applies delivery fee) and validates order minimum values correctly.
- [ ] **UC-14:** Entering invalid voucher code displays errors correctly. Valid voucher applies the correct discount value.
- [ ] **UC-15 & UC-16:** Cash payment defaults to `pending` status. Digital payment (Momo/VNPay) simulates `paid` status instantly in Demo mode.
- [ ] **UC-17:** Confirming order clears the current cart provider and transitions cleanly to `order_success_screen` with correct order details.

### 📦 History, Real-time Tracking & Reviews (UC-18, UC-19, UC-39)
- [ ] **UC-18:** Filtering history list by status (Active vs. Finished) works dynamically. Finished orders display "Đánh giá" button.
- [ ] **UC-19:** Pickup order displays dynamic brewing cup (liquid rises per status) and stepper. Delivery order displays traditional vertical stepper.
- [ ] **UC-39:** Product review bottom sheet allows selecting star rating (1-5), optional comments, and updates order model metadata state.

### ⭐ Loyalty & Reward Program (UC-27, UC-28)
- [ ] **UC-27:** Current points are calculated and displayed correctly. Point history lists all 'earn' and 'redeem' transactions.
- [ ] **UC-28:** Clicking "Đổi voucher" checks point threshold. Sufficient points deducts total, spawns a new voucher code, and displays copy icon.
