enum EncryptType {
  /// 方块混淆
  blockPixelConfusion(1),

  /// 行像素混淆
  rowPixelConfusion(2),

  /// 像素混淆
  pixelConfusion(3),

  /// 兼容PicEncrypt：行模式
  picEncryptRowConfusion(4),

  /// 兼容PicEncrypt：行+列模式
  picEncryptRowColConfusion(5);

  const EncryptType(this.value);

  final int value;
}

extension ExtEncryptType on EncryptType {
  String get typeName {
    switch (this) {
      case EncryptType.blockPixelConfusion:
        return '方块混淆 (Block Confusion)';
      case EncryptType.rowPixelConfusion:
        return '行像素混淆 (Row Pixels Confusion)';
      case EncryptType.pixelConfusion:
        return '像素混淆 (Pixels Confusion)';
      case EncryptType.picEncryptRowConfusion:
        return '兼容PicEncrypt: 行模式';
      case EncryptType.picEncryptRowColConfusion:
        return '兼容PicEncrypt: 行+列模式';
    }
  }
}
