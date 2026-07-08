import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart'; // Import file cấu hình vừa tách
import '../features/users/screens/login_screen.dart';

void main() async {
  // Bắt buộc khởi tạo binding cho các dịch vụ native
  WidgetsFlutterBinding.ensureInitialized();

  // Gọi cấu hình từ file firebase_config.dart
  await Firebase.initializeApp(options: FirebaseConfig.developmentOptions);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luxe Reserve App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark, // Phong cách Luxury mặc định Dark Mode
      home: const LoginScreen(isDarkMode: true),
    );
  }
}
