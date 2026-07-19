import 'dart:convert';

import 'package:http/http.dart' as http;

/// Kết quả geocode gọn cho form địa chỉ (UC-05).
class GeoPlace {
  const GeoPlace({
    required this.label,
    required this.street,
    required this.ward,
    required this.district,
    required this.city,
    required this.lat,
    required this.lng,
  });

  final String label; // dòng hiển thị trong danh sách gợi ý
  final String street;
  final String ward;
  final String district;
  final String city;
  final double lat;
  final double lng;
}

/// GeoService — gợi ý địa chỉ + reverse geocode cho form địa chỉ.
///
/// Stack MIỄN PHÍ trên dữ liệu OpenStreetMap, không cần API key/billing
/// (Google Places cần thẻ tín dụng — không hợp đồ án):
/// - Autocomplete: Photon (photon.komoot.io) — thiết kế riêng cho gõ-tới-đâu-
///   gợi-ý-tới-đó, cho phép dùng tự do.
/// - Reverse geocode: Nominatim — chỉ gọi 1 request/lần bấm (đúng usage
///   policy, kèm User-Agent định danh).
class GeoService {
  static const _userAgent = 'coffee-shop-prm-student-project (MIP201)';

  /// Gợi ý địa chỉ theo từ khóa. [nearLat]/[nearLng] để ưu tiên kết quả gần.
  Future<List<GeoPlace>> search(
    String query, {
    double? nearLat,
    double? nearLng,
  }) async {
    final uri = Uri.https('photon.komoot.io', '/api/', {
      'q': query,
      'limit': '6',
      'lang': 'default',
      if (nearLat != null) 'lat': '$nearLat',
      if (nearLng != null) 'lon': '$nearLng',
    });
    final res = await http
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return const [];

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final features = body['features'] as List? ?? const [];
    return features
        .map(_fromPhotonFeature)
        .whereType<GeoPlace>()
        .toList(growable: false);
  }

  GeoPlace? _fromPhotonFeature(dynamic feature) {
    try {
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final coords = geometry['coordinates'] as List; // [lon, lat]
      final p = (feature['properties'] as Map<String, dynamic>?) ?? const {};

      String s(String key) => (p[key] as String?)?.trim() ?? '';

      final houseAndStreet =
          [s('housenumber'), s('street')].where((e) => e.isNotEmpty).join(' ');
      final street = houseAndStreet.isNotEmpty ? houseAndStreet : s('name');
      final ward = s('suburb').isNotEmpty ? s('suburb') : s('locality');
      final district = s('district').isNotEmpty ? s('district') : s('county');
      final city = s('city').isNotEmpty ? s('city') : s('state');

      final parts = <String>[
        if (street.isNotEmpty) street,
        if (ward.isNotEmpty) ward,
        if (district.isNotEmpty) district,
        if (city.isNotEmpty) city,
      ];
      if (parts.isEmpty) return null;

      return GeoPlace(
        label: parts.join(', '),
        street: street,
        ward: ward,
        district: district,
        city: city,
        lat: (coords[1] as num).toDouble(),
        lng: (coords[0] as num).toDouble(),
      );
    } catch (_) {
      return null; // feature thiếu field — bỏ qua
    }
  }

  /// Tọa độ → địa chỉ (dùng cho nút GPS và chạm trên bản đồ).
  Future<GeoPlace?> reverse(double lat, double lng) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': '$lat',
      'lon': '$lng',
      'accept-language': 'vi',
    });
    final res = await http
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final a = (body['address'] as Map<String, dynamic>?) ?? const {};

    String s(String key) => (a[key] as String?)?.trim() ?? '';
    String first(List<String> keys) =>
        keys.map(s).firstWhere((v) => v.isNotEmpty, orElse: () => '');

    // Field hành chính của Nominatim ở VN RẤT loạn: có điểm để quận trong
    // 'suburb', có điểm để quận (không tiền tố) trong 'quarter'... nên dùng
    // 2 tầng:
    //   Tầng 1 — phân loại theo tiền tố tiếng Việt ("Phường/Xã…", "Quận/…")
    //   Tầng 2 — vị trí trong display_name (luôn thứ tự nhỏ→lớn:
    //   "số, đường, PHƯỜNG, QUẬN, thành phố, postcode, Việt Nam")
    final candidates = <String>[
      s('quarter'),
      s('suburb'),
      s('neighbourhood'),
      s('village'),
      s('hamlet'),
      s('city_district'),
      s('district'),
      s('county'),
      s('town'),
    ].where((v) => v.isNotEmpty).toList();

    final city = first(['city', 'state']);
    final road = s('road');
    final house = s('house_number');
    final postcode = s('postcode');

    final display = (body['display_name'] as String?) ?? '';
    final middle = display
        .split(',')
        .map((seg) => seg.trim())
        .where((seg) =>
            seg.isNotEmpty &&
            seg != house &&
            seg != postcode &&
            !RegExp(r'^\d+$').hasMatch(seg) &&
            seg != 'Việt Nam' &&
            seg != 'Vietnam' &&
            seg != city &&
            !(road.isNotEmpty &&
                seg.toLowerCase().contains(road.toLowerCase())))
        .toList();

    // Tiền tố tiếng Việt thắng tuyệt đối, tìm trong cả field lẫn display_name.
    final everywhere = [...candidates, ...middle];
    var ward = everywhere.firstWhere(_looksLikeWard, orElse: () => '');
    var district = everywhere.firstWhere(_looksLikeDistrict, orElse: () => '');

    if (ward.isEmpty && district.isEmpty) {
      // Data kiểu CŨ (không tiền tố): phần đuôi display_name là [phường, quận]
      if (middle.isNotEmpty) district = middle.last;
      if (middle.length >= 2) ward = middle[middle.length - 2];
    } else if (ward.isEmpty) {
      ward = s('quarter');
    }
    // Sáp nhập 2025 bỏ cấp quận/huyện: có "Phường X" mà không có "Quận Y"
    // là chuyện BÌNH THƯỜNG — district để trống, không nhét bừa tên khu
    // dân cư cũ (vd "Chính Gián") vào ô quận.
    if (ward == district) ward = '';

    final street = [house, road].where((e) => e.isNotEmpty).join(' ');
    return GeoPlace(
      label: (body['display_name'] as String?) ?? '',
      street: street,
      ward: ward,
      district: district,
      city: city,
      lat: lat,
      lng: lng,
    );
  }

  static bool _looksLikeWard(String v) {
    final lower = v.toLowerCase();
    return lower.startsWith('phường') ||
        lower.startsWith('xã') ||
        lower.startsWith('thôn');
  }

  static bool _looksLikeDistrict(String v) {
    final lower = v.toLowerCase();
    return lower.startsWith('quận') ||
        lower.startsWith('huyện') ||
        lower.startsWith('thị xã') ||
        lower.startsWith('thành phố thủ đức');
  }
}
