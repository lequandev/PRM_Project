import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/cafe_shop_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách sản phẩm theo bộ lọc Realtime
  Stream<List<Product>> streamProducts({String? category}) {
    Query query = _firestore.collection('products');
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                Product.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  // Lấy danh sách cửa hàng
  Future<List<CafeShop>> getCafeShops() async {
    var snapshot = await _firestore.collection('cafe_shops').get();
    return snapshot.docs
        .map((doc) => CafeShop.fromMap(doc.id, doc.data()))
        .toList();
  }
}
