import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'routes/app_router.dart';
import 'features/auth/providers/staff_auth_provider.dart';
import 'features/orders/providers/staff_order_provider.dart';
import 'features/inventory/providers/staff_inventory_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase với DefaultFirebaseOptions
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Tự động khởi tạo tài khoản nhân viên (Staff) dùng thử
    await _seedDefaultStaffUser();
    
    // Tự động seed dữ liệu mẫu (Orders và Inventory) nếu database trống
    await _seedMockData();
  } catch (e) {
    AppLogger.error('Lỗi khi khởi tạo Firebase: $e');
  }
  
  runApp(const StaffApp());
}

Future<void> _seedDefaultStaffUser() async {
  await _seedUser('staff@coffeeshop.com', 'Password123', 'Nhân viên Test');
  await _seedUser('staff_test@coffeeshop.com', 'Password123', 'Nhân viên Dự phòng');
}

Future<void> _seedUser(String email, String password, String name) async {
  try {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      
      await db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'role': 'staff',
        'phone': '0912345678',
        'loyaltyPoints': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('=== ĐÃ TẠO TÀI KHOẢN STAFF: $email / $password ===');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        AppLogger.info('=== TÀI KHOẢN STAFF SẴN SÀNG: $email ===');
        
        // Nếu user đã tồn tại trong Auth nhưng lỡ bị mất document Firestore, ta tự tạo lại
        try {
          // Để ghi được Firestore, ta cần sign in để thỏa mãn Security Rules (Owner check)
          final signInCred = await auth.signInWithEmailAndPassword(email: email, password: password);
          final uid = signInCred.user!.uid;
          await db.collection('users').doc(uid).set({
            'uid': uid,
            'email': email,
            'name': name,
            'role': 'staff',
            'phone': '0912345678',
            'loyaltyPoints': 0,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          await auth.signOut(); // Đăng xuất để trả lại trạng thái ban đầu
          AppLogger.info('=== ĐỒNG BỘ DOCUMENT FIRESTORE THÀNH CÔNG CHO: $email ===');
        } catch (dbError) {
          // Có thể sai mật khẩu cũ hoặc lỗi khác, bỏ qua
        }
      } else {
        AppLogger.error('Lỗi tạo user $email: $e');
      }
    }
  } catch (e) {
    AppLogger.error('Lỗi khởi tạo tài khoản $email: $e');
  }
}

class StaffApp extends StatefulWidget {
  const StaffApp({super.key});

  @override
  State<StaffApp> createState() => _StaffAppState();
}

class _StaffAppState extends State<StaffApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StaffAuthProvider()),
        ChangeNotifierProvider(create: (_) => StaffOrderProvider()),
        ChangeNotifierProvider(create: (_) => StaffInventoryProvider()),
      ],
      child: _showSplash
          ? MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.staff,
              home: AnimatedSplashScreen(
                onFinished: () {
                  if (mounted) setState(() => _showSplash = false);
                },
              ),
            )
          : MaterialApp.router(
              title: 'Coffee Shop — Nhân viên',
              theme: AppTheme.staff,
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
            ),
    );
  }
}

Future<void> _seedMockData() async {
  try {
    final auth = FirebaseAuth.instance;
    // Tạm đăng nhập để có quyền ghi (thoả mãn isAuth() trong rules)
    if (auth.currentUser == null) {
      await auth.signInWithEmailAndPassword(email: 'staff@coffeeshop.com', password: 'Password123');
    }
    
    final db = FirebaseFirestore.instance;
    
    // 1. Seed Inventory
    final inventorySnap = await db.collection('inventory').limit(1).get();
    if (inventorySnap.docs.isEmpty) {
      AppLogger.info('=== BẮT ĐẦU SEED INVENTORY COFFEE SHOP ===');
      final defaultIngredients = [
        {'name': 'Hạt cà phê Robusta', 'unit': 'kg', 'currentStock': 15.0, 'minStock': 5.0, 'status': 'available'},
        {'name': 'Hạt cà phê Arabica', 'unit': 'kg', 'currentStock': 8.0, 'minStock': 3.0, 'status': 'available'},
        {'name': 'Sữa đặc Ngôi Sao Phương Nam', 'unit': 'hộp', 'currentStock': 2.0, 'minStock': 5.0, 'status': 'low'},
        {'name': 'Sữa tươi tiệt trùng Barista', 'unit': 'lít', 'currentStock': 0.0, 'minStock': 6.0, 'status': 'out_of_stock'},
        {'name': 'Đường cát', 'unit': 'kg', 'currentStock': 10.0, 'minStock': 2.0, 'status': 'available'},
        {'name': 'Siro Caramel Torani', 'unit': 'chai', 'currentStock': 3.0, 'minStock': 1.0, 'status': 'available'},
        {'name': 'Trà đen Phúc Long', 'unit': 'kg', 'currentStock': 4.0, 'minStock': 2.0, 'status': 'available'},
        {'name': 'Cốc nhựa 500ml', 'unit': 'cái', 'currentStock': 250.0, 'minStock': 100.0, 'status': 'available'},
      ];
      for (final item in defaultIngredients) {
        await db.collection('inventory').add({
          ...item,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': 'System Seeder',
        });
      }
      AppLogger.info('=== SEED INVENTORY THÀNH CÔNG ===');
    }

    // 2. Seed Mock Orders
    final ordersSnap = await db.collection('orders').limit(1).get();
    if (ordersSnap.docs.isEmpty) {
      AppLogger.info('=== BẮT ĐẦU SEED MOCK ORDERS COFFEE SHOP ===');
      final mockOrders = [
        {
          'customerId': 'cust_01',
          'customerName': 'Nguyễn Văn A',
          'customerPhone': '0987654321',
          'subtotal': 64000.0,
          'discountAmount': 10000.0,
          'totalAmount': 54000.0,
          'status': 'pending',
          'orderType': 'pickup',
          'paymentMethod': 'cash',
          'paymentStatus': 'pending',
          'note': 'Cà phê ít ngọt, nhiều đá nhé shop ơi.',
          'loyaltyPointsEarned': 5,
          'loyaltyPointsUsed': 0,
          'items': [
            {
              'productId': 'prod_01',
              'productName': 'Cà phê sữa đá',
              'quantity': 2,
              'unitPrice': 32000.0,
              'totalPrice': 64000.0,
              'customizations': {'Size': 'M', 'Đá': 'Nhiều đá', 'Ngọt': 'Ít ngọt'},
            }
          ],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'customerId': 'cust_02',
          'customerName': 'Trần Thị B',
          'customerPhone': '0912345678',
          'subtotal': 45000.0,
          'discountAmount': 0.0,
          'totalAmount': 45000.0,
          'status': 'preparing',
          'orderType': 'delivery',
          'deliveryAddress': {
            'receiverName': 'Trần Thị B',
            'receiverPhone': '0912345678',
            'addressDetail': 'Tòa nhà FPT, Phố Duy Tân',
            'latitude': 21.0285,
            'longitude': 105.7801,
          },
          'paymentMethod': 'momo',
          'paymentStatus': 'paid',
          'note': 'Giao gấp trước 2h trưa giúp mình nhé.',
          'loyaltyPointsEarned': 4,
          'loyaltyPointsUsed': 0,
          'items': [
            {
              'productId': 'prod_02',
              'productName': 'Trà đào cam sả',
              'quantity': 1,
              'unitPrice': 45000.0,
              'totalPrice': 45000.0,
              'customizations': {'Size': 'L', 'Đá': 'Thường', 'Đường': 'Thường'},
            }
          ],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'customerId': 'cust_03',
          'customerName': 'Lê Minh C',
          'customerPhone': '0901234567',
          'subtotal': 75000.0,
          'discountAmount': 5000.0,
          'totalAmount': 70000.0,
          'status': 'ready',
          'orderType': 'pickup',
          'paymentMethod': 'card',
          'paymentStatus': 'paid',
          'note': 'Không lấy ống hút nhựa.',
          'loyaltyPointsEarned': 7,
          'loyaltyPointsUsed': 5,
          'items': [
            {
              'productId': 'prod_03',
              'productName': 'Bạc xỉu nóng',
              'quantity': 1,
              'unitPrice': 35000.0,
              'totalPrice': 35000.0,
              'customizations': {'Size': 'S'},
            },
            {
              'productId': 'prod_04',
              'productName': 'Bánh croissant sừng bò',
              'quantity': 1,
              'unitPrice': 40000.0,
              'totalPrice': 40000.0,
              'customizations': {},
            }
          ],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'acceptedAt': FieldValue.serverTimestamp(),
          'readyAt': FieldValue.serverTimestamp(),
        }
      ];

      for (final order in mockOrders) {
        await db.collection('orders').add(order);
      }
      AppLogger.info('=== SEED MOCK ORDERS THÀNH CÔNG ===');
    }
  } catch (e) {
    AppLogger.error('Lỗi khi seed mock data: $e');
  }
}
