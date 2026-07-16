// ══════════════════════════════════════════════════════════════
// ☕ COFFEE SHOP — MONOREPO ROOT
// ══════════════════════════════════════════════════════════════
//
// File này là PLACEHOLDER — root project chỉ là Git container.
// KHÔNG chạy file này trực tiếp.
//
// Để chạy đúng app, mở project tương ứng:
//
//   📱 Customer App  →  mở thư mục: app_customer/
//   👨‍🍳 Staff App    →  mở thư mục: app_staff/
//   📊 Admin App     →  mở thư mục: app_admin/
//   📦 Core Module   →  mở thư mục: core_module/  (Dev 1 only)
//
// Xem hướng dẫn chi tiết:
//   - TECH_STACK.md
//   - FIRESTORE_SCHEMA.md
//   - core_module/README.md
//   - Team_Workflow_Coffee_Shop_V2.md
//
// ── Phân công ──────────────────────────────────────────────
//   Dev 1  →  core_module/ + Firebase backend (UC-01,02,03,34,36)
//   Dev 2  →  app_customer/ menu & cart (UC-07→12)
//   Dev 3  →  app_customer/ checkout & orders (UC-13→19, UC-27,28,39)
//   Dev 4  →  app_staff/ (UC-20→26)
//   Dev 5  →  app_admin/ (UC-29→40)
// ══════════════════════════════════════════════════════════════

void main() {
  // Root project không chạy — đây chỉ là Git container.
  // Chạy từng app riêng lẻ trong thư mục app_customer/app_staff/app_admin.
  throw UnsupportedError(
    'Chạy sai app! Mở đúng thư mục: app_customer / app_staff / app_admin',
  );
}
