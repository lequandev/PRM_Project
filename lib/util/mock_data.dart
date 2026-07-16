import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> importLuxeMockData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 1. Danh sách sản phẩm (Products Mock Data)
  List<Map<String, dynamic>> productsMock = [
    {
      "name": "Kyoto Cold Brew",
      "description": "Slow-drip Japanese style cold coffee",
      "price": 4.50,
      "image":
          "https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&q=80&w=600",
      "category": "coffee",
      "rating": 4.9,
      "reviewsCount": 120,
      "isNew": true,
      "isBestSeller": true,
      "isPopular": false,
    },
    {
      "name": "Croissant Premium",
      "description": "Buttery flaky French pastry baked fresh",
      "price": 3.20,
      "image":
          "https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&q=80&w=600",
      "category": "cake",
      "rating": 4.7,
      "reviewsCount": 85,
      "isNew": false,
      "isBestSeller": false,
      "isPopular": true,
    },
    {
      "name": "Matcha Detox Latte",
      "description": "Pure Uji matcha layered with organic almond milk",
      "price": 5.00,
      "image":
          "https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&q=80&w=600",
      "category": "tea",
      "rating": 4.8,
      "reviewsCount": 94,
      "isNew": true,
      "isBestSeller": false,
      "isPopular": true,
    },
    {
      "name": "Club Sandwich",
      "description": "Classic triple-decker with smoked turkey and avocado",
      "price": 6.50,
      "image":
          "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&q=80&w=600",
      "category": "dessert",
      "rating": 4.5,
      "reviewsCount": 60,
      "isNew": false,
      "isBestSeller": false,
      "isPopular": false,
    },
  ];

  // 2. Danh sách cửa hàng (Cafe Shops Mock Data)
  List<Map<String, dynamic>> shopsMock = [
    {
      "name": "Luxe Lounge Ngu Hanh Son",
      "address":
          "Tan Thanh Block, Hoa Hai Ward, Ngu Hanh Son District, Da Nang City",
      "distance": "0.8 km",
    },
    {
      "name": "Luxe Academy Hoa Lac",
      "address": "High-Tech Park, Hoa Lac, Thach That, Ha Noi Capital",
      "distance": "2.5 km",
    },
  ];

  // Thực hiện đẩy dữ liệu lên Firestore bằng phương thức .add() để sinh ID tự động
  try {
    // Thêm các sản phẩm
    for (var product in productsMock) {
      await firestore.collection('products').add(product);
    }

    // Thêm các cửa hàng
    for (var shop in shopsMock) {
      await firestore.collection('cafe_shops').add(shop);
    }

    print("🎉 Import dữ liệu Mock Data thành công với ID ngẫu nhiên!");
  } catch (e) {
    print("❌ Lỗi khi import dữ liệu: $e");
  }
}
