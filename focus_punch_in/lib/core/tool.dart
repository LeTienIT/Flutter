class Tool {
  static String? categoryValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hãy nhập giá trị';
    }
    return null;
  }

  static String? amountValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hãy nhập giá trị';
    }
    if (int.tryParse(value) == null) {
      return 'Hãy nhập đúng định dạng số nguyên 1, 3, 4, ...';
    }
    if(int.tryParse(value)! < 0){
      return 'Hãy nhập số LỚN HƠN hoặc BẰNG [0]';
    }
    return null;
  }

  static String? notEmpty(String? value, {String message = 'Không được để trống'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }
}