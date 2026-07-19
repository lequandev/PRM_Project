# ☕ Dev 4 Verification Checklist (Staff App: Operations & Inventory)

This markdown checklist outlines the tasks, file structures, logic assessment, and verification steps for checking the completion of Dev 4's assignments.

---

## 📋 Task Mapping & Status

| Use Case | Description | Status | Implementation Code |
| :--- | :--- | :---: | :--- |
| **UC-20** | Order Queue List | ✅ Completed | [order_queue_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/orders/screens/order_queue_screen.dart)<br>[staff_order_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/orders/providers/staff_order_provider.dart) |
| **UC-21** | Accept / Reject Order | ✅ Completed | [order_detail_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/orders/screens/order_detail_screen.dart) |
| **UC-22** | Update Status to "Preparing" | ✅ Completed | [order_detail_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/orders/screens/order_detail_screen.dart) |
| **UC-23** | Update Status to "Ready" | ✅ Completed | [order_detail_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/orders/screens/order_detail_screen.dart) |
| **UC-24** | Confirm Handover / Delivery | ✅ Completed | [order_detail_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/orders/screens/order_detail_screen.dart) |
| **UC-25** | Print Invoice | ✅ Completed | [order_detail_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/orders/screens/order_detail_screen.dart) |
| **UC-26** | Cancel Active Order with Reason | ✅ Completed | [order_detail_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/orders/screens/order_detail_screen.dart) |
| **UC-35 (Staff)** | Update Stock Status / Out of Stock | ✅ Completed | [inventory_screen.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/inventory/screens/inventory_screen.dart)<br>[staff_inventory_provider.dart](file:///d:/Ky8/FinalPRM/prm_project/app_staff/lib/features/inventory/providers/staff_inventory_provider.dart) |

---

## 🛠️ File Structure Audit

Ensure that all files reside in the correct packages/features directories within `/app_staff` (no editing of `/core_module` or `/app_customer`):

### 1. Orders Feature (`/features/orders`)
- **Screens:**
  - `order_queue_screen.dart` (Main dashboard for incoming orders, tabbed by status)
  - `order_detail_screen.dart` (Detailed order card, status transitions, print actions, cancel dialog)
- **Providers:**
  - `staff_order_provider.dart` (Active orders queue manager, handles Firestore status updates)

### 2. Inventory Feature (`/features/inventory`)
- **Screens:**
  - `inventory_screen.dart` (View raw ingredients list, toggle availability)
- **Providers:**
  - `staff_inventory_provider.dart` (Manages stock levels and Firestore inventory updates)

### 3. App Shell & Routing (`/screens` & `/routes`)
- **Shell Screen:**
  - `main_shell_screen.dart` (Navigation bar with Orders Queue and Inventory tabs)
- **Router:**
  - `app_router.dart` (Staff App routing configurations)

---

## 🧪 Verification & Acceptance Criteria

### 📦 Order Processing (UC-20, UC-21, UC-22, UC-23, UC-24, UC-26)
- [ ] **UC-20:** Order queue updates in real-time when new orders are placed by customers.
- [ ] **UC-21:** Staff can accept a pending order (updates status to `accepted`) or reject it.
- [ ] **UC-22:** Staff can update status to "Preparing" (updates status to `preparing`).
- [ ] **UC-23:** Staff can update status to "Ready" (updates status to `ready`).
- [ ] **UC-24:** Staff can mark the order as "Delivered / Handed Over" (updates status to `delivered`).
- [ ] **UC-26:** Staff can cancel any active order at any stage, requiring a reason from a dialog.

### 🧾 Invoice Printing (UC-25)
- [ ] **UC-25:** Clicking "Print Invoice" triggers the system printer dialog or generates a clean, mock PDF invoice preview.

### 🍅 Inventory Management (UC-35 Staff)
- [ ] **UC-35:** Staff can view all ingredients, filter by low stock, and manually toggle/update ingredient availability which syncs to Firestore database.
