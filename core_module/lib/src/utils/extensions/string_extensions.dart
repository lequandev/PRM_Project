/// String extensions dùng chung toàn dự án.
/// Dev 1 owns — không tự sửa ngoài core_module.
extension StringExtensions on String {
  /// Kiểm tra email hợp lệ
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Kiểm tra số điện thoại Việt Nam hợp lệ (10 số, bắt đầu 0)
  bool get isValidVietnamesePhone {
    return RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$').hasMatch(this);
  }

  /// Viết hoa chữ cái đầu mỗi từ
  String get titleCase {
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Viết hoa chữ cái đầu câu
  String get sentenceCase {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Rút gọn chuỗi nếu quá dài
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Xóa dấu tiếng Việt (dùng cho search)
  String get withoutDiacritics {
    const diacritics =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñÐðŸẠẮẶẬẤẦẲẴẼẸẾỆỀỂẼ'
        'ẺẼỊỌỘỚỢỜỚỐỒỔỖỤỰỨỪỬỮỲỴỶỸÝỳýỵỷỹ'
        'ĂắặậấầẳẵĐđ'
        'àáâãèéêìíòóôõùúýăđĩũơưạảấầẩẫậắằẳẵặẹẻẽếềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ';
    const nonDiacritics =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeC cIIIIiiiiUUUUuuuuyNnDdYaaaaaaaaaaaeee'
        'eeeeeiooooouuuuuyyyy'
        'AaaaaaDd'
        'aaaeeeiiooooouuyadadaaaaaaaaaaaaaaeeeeeeeeiiooooooooouuuuuuuyyyyy';

    String result = this;
    for (int i = 0; i < diacritics.length; i++) {
      if (i < nonDiacritics.length) {
        result = result.replaceAll(diacritics[i], nonDiacritics[i]);
      }
    }
    return result;
  }

  /// Check chuỗi rỗng sau khi trim
  bool get isBlank => trim().isEmpty;

  /// Null-safe version: trả về null nếu blank
  String? get nullIfBlank => isBlank ? null : trim();
}

extension NullableStringExtensions on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}
