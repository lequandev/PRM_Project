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
    // await _seedMockData();
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

@pragma('vm:entry-point')
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

    // Cleanup legacy corrupt mock orders first to prevent parsing errors
    final mockOrdersSnap = await db.collection('orders')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'order_mock_')
        .where(FieldPath.documentId, isLessThanOrEqualTo: 'order_mock_\uf8ff')
        .get();
    for (final doc in mockOrdersSnap.docs) {
      try {
        await doc.reference.delete();
        AppLogger.info('Deleted corrupt legacy mock order: ${doc.id}');
      } catch (e) {
        AppLogger.error('Error deleting mock order ${doc.id}: $e');
      }
    }

    // Seed Orders if there are no delivered orders (to draw the revenue charts)
    final orderSnap = await db.collection('orders').where('status', isEqualTo: 'delivered').limit(1).get();
    if (orderSnap.docs.isEmpty) {
      AppLogger.info('=== SEED ORDERS ===');
      final productsListSnap = await db.collection('products').get();
      if (productsListSnap.docs.isNotEmpty) {
        final prod1 = productsListSnap.docs[0];
        final prod2 = productsListSnap.docs.length > 1 ? productsListSnap.docs[1] : prod1;
        
        final now = DateTime.now();
        // Create 10 orders spread across the last 7 days
        for (int i = 0; i < 10; i++) {
          final orderDate = now.subtract(Duration(days: i, hours: i * 2));
          final docId = 'order_mock_${now.millisecondsSinceEpoch}_$i'; // unique doc ID
          
          final price1 = (prod1.data()['basePrice'] as num?)?.toDouble() ?? 30000.0;
          final price2 = (prod2.data()['basePrice'] as num?)?.toDouble() ?? 25000.0;
          final qty1 = 2;
          final qty2 = 1;
          
          final double subtotal = (price1 * qty1) + (i % 3 == 0 ? (price2 * qty2) : 0.0);
          final double totalAmount = subtotal + 15000.0; // subtotal + 15k delivery fee
          
          await db.collection('orders').doc(docId).set({
            'customerId': 'customer_test',
            'customerName': i % 2 == 0 ? 'Nguyễn Trần Huy' : 'Lê Thị Mai',
            'customerPhone': '0987654321',
            'items': [
              {
                'productId': prod1.id,
                'productName': prod1.data()['name'] ?? 'Cà phê',
                'productImageUrl': prod1.data()['imageUrl'] as String?,
                'quantity': qty1,
                'unitPrice': price1,
                'totalPrice': price1 * qty1,
                'customizations': {},
              },
              if (i % 3 == 0)
                {
                  'productId': prod2.id,
                  'productName': prod2.data()['name'] ?? 'Bánh ngọt',
                  'productImageUrl': prod2.data()['imageUrl'] as String?,
                  'quantity': qty2,
                  'unitPrice': price2,
                  'totalPrice': price2 * qty2,
                  'customizations': {},
                }
            ],
            'subtotal': subtotal,
            'discountAmount': 0.0,
            'totalAmount': totalAmount,
            'status': i == 9 ? 'cancelled' : 'delivered', // 1 cancelled, others delivered
            'orderType': 'delivery',
            'paymentMethod': i % 2 == 0 ? 'cash' : 'momo',
            'paymentStatus': 'paid',
            'createdAt': Timestamp.fromDate(orderDate),
            'updatedAt': Timestamp.fromDate(orderDate),
          });
        }
      }
    }

    // Seed Reviews subcollection using fixed document IDs to prevent duplication
    final productsListSnapForReview = await db.collection('products').get();
    if (productsListSnapForReview.docs.isNotEmpty) {
      final targetProductDoc = productsListSnapForReview.docs.first;
      
      // Clean up any legacy random mock reviews first
      final mockUserIds = ['user_rv1', 'user_rv2', 'user_rv3'];
      final existingReviewsSnap = await targetProductDoc.reference.collection('reviews')
          .where('userId', whereIn: mockUserIds)
          .get();
      for (final doc in existingReviewsSnap.docs) {
        try {
          await doc.reference.delete();
        } catch (e) {
          AppLogger.error('Error cleaning up review ${doc.id}: $e');
        }
      }

      AppLogger.info('=== SEED REVIEWS (FIXED IDS) ===');
      final mockReviews = {
        'review_mock_1': {
          'userId': 'user_rv1',
          'userName': 'Hoàng Nam',
          'rating': 5.0,
          'comment': 'Đồ uống rất ngon, đậm đà vị cà phê truyền thống. Nhân viên thân thiện!',
          'status': 'pending', // pending review
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        },
        'review_mock_2': {
          'userId': 'user_rv2',
          'userName': 'Minh Thư',
          'rating': 4.0,
          'comment': 'Bánh croissant giòn tan nhưng nước hơi ngọt quá, giảm đường sẽ ngon hơn.',
          'status': 'pending', // pending review
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
        },
        'review_mock_3': {
          'userId': 'user_rv3',
          'userName': 'Khánh Vy',
          'rating': 5.0,
          'comment': 'Không gian đẹp, giao hàng siêu nhanh. Sẽ đặt lại thường xuyên.',
          'status': 'approved', // approved review
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        }
      };
      
      for (final entry in mockReviews.entries) {
        await targetProductDoc.reference.collection('reviews').doc(entry.key).set(entry.value);
      }
    }

    // Seed Ingredients if collection is empty
    final ingSnap = await db.collection('ingredients').limit(1).get();
    if (ingSnap.docs.isEmpty) {
      AppLogger.info('=== SEED INGREDIENTS ===');
      final ingredients = [
        {
          'name': 'Hạt cà phê Robusta',
          'quantity': 4.5, // 4.5 kg - low stock alert
          'unit': 'kg',
          'minThreshold': 10.0, // Alert threshold
          'supplier': 'Nông trại Buôn Ma Thuột',
          'lastImportedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10))),
        },
        {
          'name': 'Sữa đặc Ông Thọ',
          'quantity': 24.0, // 24 cans - plenty
          'unit': 'lon',
          'minThreshold': 12.0,
          'supplier': 'Vinamilk Việt Nam',
          'lastImportedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        },
        {
          'name': 'Bột Matcha Uji',
          'quantity': 0.8, // 0.8 kg - low stock alert
          'unit': 'kg',
          'minThreshold': 2.0,
          'supplier': 'Uji Matcha Importers',
          'lastImportedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
        },
        {
          'name': 'Cam tươi sành',
          'quantity': 15.0, // 15 kg - plenty
          'unit': 'kg',
          'minThreshold': 5.0,
          'supplier': 'Chợ đầu mối Long Biên',
          'lastImportedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        }
      ];
      for (final ing in ingredients) {
        await db.collection('ingredients').add(ing);
      }
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
