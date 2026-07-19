import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'features/auth/providers/admin_auth_provider.dart';
import 'features/menu_management/providers/admin_product_provider.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'features/marketing/providers/voucher_provider.dart';
import 'features/marketing/providers/notification_provider.dart';
import 'features/store_settings/providers/store_config_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/reviews/providers/review_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Seed tài khoản admin mặc định để dùng thử
    await _seedDefaultAdminUser();

    // Seed mock data nếu DB trống
    await _seedMockData();
  } catch (e) {
    AppLogger.error('Lỗi khởi tạo Firebase: $e');
  }

  // Khởi tạo locale vi_VN cho DateFormat
  await initializeDateFormatting('vi_VN', null);

  runApp(const AdminApp());
}

// ─── Seed Admin User ──────────────────────────────────────────────────────────

Future<void> _seedDefaultAdminUser() async {
  await _seedAdminAccount('admin@coffeeshop.com', 'Admin@123', 'Quản lý Admin');
}

Future<void> _seedAdminAccount(
    String email, String password, String name) async {
  try {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;

    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      await db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'role': 'admin',
        'phone': '0901234567',
        'loyaltyPoints': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('=== ĐÃ TẠO TÀI KHOẢN ADMIN: $email / $password ===');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        AppLogger.info('=== TÀI KHOẢN ADMIN SẴN SÀNG: $email ===');
      } else {
        AppLogger.error('Lỗi tạo admin: $e');
      }
    }
  } catch (e) {
    AppLogger.error('Lỗi seed admin: $e');
  }
}

// ─── Seed Mock Data ───────────────────────────────────────────────────────────

Future<void> _seedMockData() async {
  try {
    final db = FirebaseFirestore.instance;

    // Seed Categories
    final catSnap = await db.collection('categories').limit(1).get();
    if (catSnap.docs.isEmpty) {
      AppLogger.info('=== SEED CATEGORIES ===');
      final cats = [
        {'name': 'Cà phê', 'displayOrder': 1, 'isActive': true},
        {'name': 'Trà & Nước ép', 'displayOrder': 2, 'isActive': true},
        {'name': 'Bánh & Snack', 'displayOrder': 3, 'isActive': true},
        {'name': 'Đặc biệt', 'displayOrder': 4, 'isActive': true},
      ];
      for (final c in cats) {
        await db.collection('categories').add(c);
      }
    }

    // Seed Products
    final prodSnap = await db.collection('products').limit(1).get();
    if (prodSnap.docs.isEmpty) {
      AppLogger.info('=== SEED PRODUCTS ===');
      final catDocs = await db.collection('categories').get();
      final catId = catDocs.docs.isNotEmpty ? catDocs.docs.first.id : 'cat_01';
      final products = [
        {
          'name': 'Cà phê sữa đá',
          'categoryId': catId,
          'basePrice': 32000.0,
          'description': 'Cà phê Robusta đậm đà pha với sữa đặc, thêm đá',
          'isAvailable': true,
          'isArchived': false,
          'tags': ['bestseller'],
          'avgRating': 4.8,
          'totalReviews': 120,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Bạc xỉu nóng',
          'categoryId': catId,
          'basePrice': 35000.0,
          'description': 'Sữa nóng nhiều, cà phê ít - thức uống buổi sáng',
          'isAvailable': true,
          'isArchived': false,
          'tags': ['hot'],
          'avgRating': 4.5,
          'totalReviews': 85,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Trà đào cam sả',
          'categoryId': catId,
          'basePrice': 45000.0,
          'description': 'Trà đào thơm mát pha với cam tươi và sả',
          'isAvailable': true,
          'isArchived': false,
          'tags': ['new', 'bestseller'],
          'avgRating': 4.7,
          'totalReviews': 60,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Cappuccino',
          'categoryId': catId,
          'basePrice': 55000.0,
          'description': 'Espresso với milk foam theo kiểu Ý',
          'isAvailable': true,
          'isArchived': false,
          'tags': ['hot'],
          'avgRating': 4.6,
          'totalReviews': 45,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Bánh croissant sừng bò',
          'categoryId': catId,
          'basePrice': 40000.0,
          'description': 'Bánh bơ Pháp giòn tan, ăn kèm cà phê',
          'isAvailable': false,
          'isArchived': false,
          'tags': [],
          'avgRating': 4.3,
          'totalReviews': 30,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];
      for (final p in products) {
        await db.collection('products').add(p);
      }
    }

    // Seed Vouchers
    final voucherSnap = await db.collection('vouchers').limit(1).get();
    if (voucherSnap.docs.isEmpty) {
      AppLogger.info('=== SEED VOUCHERS ===');
      final now = DateTime.now();
      await db.collection('vouchers').doc('COFFEE20').set({
        'code': 'COFFEE20',
        'description': 'Giảm 20% cho đơn từ 50k',
        'discountType': 'percentage',
        'discountValue': 20.0,
        'maxDiscountAmount': 30000.0,
        'minOrderValue': 50000.0,
        'usageLimit': 100,
        'usageCount': 15,
        'perUserLimit': 1,
        'isActive': true,
        'startDate': now.subtract(const Duration(days: 1)),
        'expiresAt': now.add(const Duration(days: 30)),
        'createdBy': 'admin@coffeeshop.com',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await db.collection('vouchers').doc('FREESHIP').set({
        'code': 'FREESHIP',
        'description': 'Miễn phí giao hàng cho đơn từ 100k',
        'discountType': 'fixed',
        'discountValue': 15000.0,
        'minOrderValue': 100000.0,
        'usageLimit': 50,
        'usageCount': 8,
        'perUserLimit': 2,
        'isActive': true,
        'startDate': now.subtract(const Duration(days: 5)),
        'expiresAt': now.add(const Duration(days: 14)),
        'createdBy': 'admin@coffeeshop.com',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Seed Store Config
    final configSnap =
        await db.collection('config').doc('store').get();
    if (!configSnap.exists) {
      AppLogger.info('=== SEED STORE CONFIG ===');
      await db.collection('config').doc('store').set({
        'storeName': 'Coffee Shop ☕',
        'address': '123 Phố Duy Tân, Cầu Giấy, Hà Nội',
        'phone': '024 9999 8888',
        'openTime': '07:00',
        'closeTime': '22:00',
        'isOpen': true,
        'deliveryFee': 15000.0,
        'minDeliveryOrder': 50000.0,
        'loyaltyRate': 0.01,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    AppLogger.error('Lỗi seed mock data: $e');
  }
}

// ─── App Root ─────────────────────────────────────────────────────────────────

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => StoreConfigProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      // Dùng Consumer + cached router để tránh Duplicate GlobalKey
      child: _AdminRouterApp(),
    );
  }
}

/// Tách riêng widget có router — tạo GoRouter đúng MỘT LẦN trong initState
/// để tránh Duplicate GlobalKey khi auth provider thay đổi.
class _AdminRouterApp extends StatefulWidget {
  const _AdminRouterApp();

  @override
  State<_AdminRouterApp> createState() => _AdminRouterAppState();
}

class _AdminRouterAppState extends State<_AdminRouterApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ tạo router lần đầu
    _router ??= createAdminRouter(context.read<AdminAuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Coffee Shop — Admin',
      theme: AppTheme.admin,
      routerConfig: _router!,
      debugShowCheckedModeBanner: false,
    );
  }
}
