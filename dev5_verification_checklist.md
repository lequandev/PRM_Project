# ☕ Dev 5 Verification Checklist (Admin App: Management & Analytics)

This markdown checklist outlines the tasks, file structures, logic assessment, and verification steps for checking the completion of Dev 5's assignments.

---

## 📋 Task Mapping & Status

| Use Case | Description | Status | Implementation Code |
| :--- | :--- | :---: | :--- |
| **UC-29** | Create & Manage Vouchers | ❌ Not Started | *No files implemented yet* |
| **UC-30** | Send Push Notifications | ❌ Not Started | *No files implemented yet* |
| **UC-31** | Create New Menu Products | ❌ Not Started | *No files implemented yet* |
| **UC-32** | Update Product Details | ❌ Not Started | *No files implemented yet* |
| **UC-33** | Delete / Archive Products (Soft-delete) | ❌ Not Started | *No files implemented yet* |
| **UC-34 (UI)** | Monitor Ingredient Inventory levels | ❌ Not Started | *No files implemented yet* |
| **UC-35 (Admin)** | Update Inventory Stock / Mark Out of Stock | ❌ Not Started | *No files implemented yet* |
| **UC-36 (UI)** | Manage Store Configuration Settings | ❌ Not Started | *No files implemented yet* |
| **UC-37** | Generate Revenue Reports | ❌ Not Started | *No files implemented yet* |
| **UC-38** | Analyze Best Selling Products chart | ❌ Not Started | *No files implemented yet* |
| **UC-40** | Moderate Product Reviews & Feedback | ❌ Not Started | *No files implemented yet* |

---

## 🛠️ File Structure Audit

Ensure that all files reside in the correct packages/features directories within `/app_admin` once implemented:

### 1. Catalog Feature (`/features/menu_management`)
- **Expected Screens:**
  - Create and edit forms for products and customizations.
  - Active and archived list view of catalog items.

### 2. Inventory Feature (`/features/inventory`)
- **Expected Screens:**
  - Ingredient stock level tracking panel.
  - Min-stock warning indicators and status adjustment tools.

### 3. Marketing Feature (`/features/marketing`)
- **Expected Screens:**
  - Voucher creation form and tracking usage counts.
  - Push notification broadcasting terminal.

### 4. Analytics Feature (`/features/analytics`)
- **Expected Screens:**
  - Revenue chart visualizer and sales report downloads.
  - Review moderation panel (Approve / Reject review statuses).

---

## 🧪 Verification & Acceptance Criteria

### 🎟️ Marketing & Promotions (UC-29, UC-30)
- [ ] **UC-29:** Admin can create, toggle active status, and set usage limits on Vouchers.
- [ ] **UC-30:** Admin can send a broadcast message simulating a push notification to customer devices.

### 🍕 Catalog Management (UC-31, UC-32, UC-33)
- [ ] **UC-31 & UC-32:** Adding or editing products correctly syncs properties (Name, Base Price, Category ID, Customizations list) to Firestore.
- [ ] **UC-33:** Archiving a product soft-deletes it (`isArchived = true`) without breaking historical orders referencing it.

### 📦 Inventory & Config (UC-34, UC-35 Admin, UC-36 Admin)
- [ ] **UC-34 & UC-35:** Stock levels update, triggering "Low Stock" or "Out of Stock" alerts.
- [ ] **UC-36:** Changes to Store Config (Store Name, Hours, Delivery Fees, Loyalty rates) update the singleton config document in Firestore.

### 📊 Reports & Moderation (UC-37, UC-38, UC-40)
- [ ] **UC-37 & UC-38:** Charts (like `fl_chart`) display accurate graphical trends for revenue and top-selling items.
- [ ] **UC-40:** Admin can review customer product reviews and mark status as `approved` or `rejected`.
