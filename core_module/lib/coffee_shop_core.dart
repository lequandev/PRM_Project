/// Coffee Shop Core Module
///
/// Import duy nhất cần dùng trong tất cả apps:
///   import 'package:coffee_shop_core/coffee_shop_core.dart';
///
/// Dev 1 cập nhật file này khi thêm export mới.
library coffee_shop_core;

// ════════════════════════════════════════════════
// MODELS — Tất cả Dev dùng, chỉ Dev 1 sửa
// ════════════════════════════════════════════════

// Common
export 'src/models/common/app_exception.dart';

// User
export 'src/models/user/user_model.dart';
export 'src/models/user/address_model.dart';
export 'src/models/user/loyalty_transaction_model.dart';

// Product
export 'src/models/product/product_model.dart';
export 'src/models/product/category_model.dart';
export 'src/models/product/customization_model.dart';
export 'src/models/product/review_model.dart';

// Order
export 'src/models/order/order_model.dart';
export 'src/models/order/order_item_model.dart';
export 'src/models/order/order_status.dart';  // Enums: OrderStatus, OrderType, PaymentMethod, UserRole

// Voucher
export 'src/models/voucher/voucher_model.dart';

// Inventory
export 'src/models/inventory/ingredient_model.dart';

// ════════════════════════════════════════════════
// SERVICES — Dev 1 owns, other devs call only
// ════════════════════════════════════════════════

// ✅ FULLY IMPLEMENTED — Dev 1 tasks
export 'src/services/auth_service.dart';          // UC-01, UC-02, UC-03
export 'src/services/inventory_service.dart';     // UC-34
export 'src/services/store_config_service.dart';  // UC-36

// 🔌 STUBS — Implemented on request from Dev 2/3/4/5
export 'src/services/product_service.dart';
export 'src/services/user_service.dart';
export 'src/services/order_service.dart';
export 'src/services/voucher_service.dart';
export 'src/services/storage_service.dart';

// ════════════════════════════════════════════════
// THEME — Tất cả Dev dùng, chỉ Dev 1 sửa
// ════════════════════════════════════════════════

export 'src/theme/app_colors.dart';
export 'src/theme/app_typography.dart';
export 'src/theme/app_theme.dart';
export 'src/theme/app_spacing.dart';

// ════════════════════════════════════════════════
// UTILS — Tất cả Dev dùng, chỉ Dev 1 sửa
// ════════════════════════════════════════════════

export 'src/utils/extensions/string_extensions.dart';
export 'src/utils/extensions/datetime_extensions.dart';
export 'src/utils/extensions/num_extensions.dart';
export 'src/utils/validators/form_validators.dart';
export 'src/utils/helpers/logger.dart';
