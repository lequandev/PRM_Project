import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/products/screens/home_screen.dart';
import 'features/users/services/auth_service.dart';
import 'util/mock_data.dart';

// ĐỔI DÒNG NÀY: Thay thế bằng đường dẫn thực tế tới file chứa class DefaultFirebaseOptions của bạn
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lúc này DefaultFirebaseOptions sẽ được nhận diện chính xác nhờ dòng import phía trên
  await Firebase.initializeApp(options: FirebaseConfig.developmentOptions);
  // Chỉ chạy khi cần import dữ liệu
  // Sau khi import xong hãy comment dòng này lại
  await importLuxeMockData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luxe Premium Lounge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: FutureBuilder<String?>(
        future: AuthService().getSavedUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen(isDarkMode: true);
          }

          return const HomeScreen(isDarkMode: true);
        },
      ),
    );
  }
}
