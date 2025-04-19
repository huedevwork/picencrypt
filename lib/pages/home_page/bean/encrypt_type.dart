import 'package:get/get.dart';

enum EncryptType {
  /// 方块混淆
  blockPixelConfusion(value: 1, childDirPath: '1_block_pixel'),

  /// 行像素混淆
  rowPixelConfusion(value: 2, childDirPath: '2_row_pixel'),

  /// 像素混淆
  pixelConfusion(value: 3, childDirPath: '3_pixel'),

  /// 兼容PicEncrypt：行模式
  picEncryptRowConfusion(value: 4, childDirPath: '4_pic_encrypt_row'),

  /// 兼容PicEncrypt：行+列模式
  picEncryptRowColConfusion(value: 5, childDirPath: '5_pic_encrypt_row_col'),

  /// 空间填充曲线混淆
  gilbert2dConfusion(value: 6, childDirPath: '6_gilbert2d');

  const EncryptType({required this.value, required this.childDirPath});

  final int value;
  final String childDirPath;

  static EncryptType getByName(String name) {
    EncryptType? type = EncryptType.values.firstWhereOrNull(
      (element) => element.name == name,
    );
    return type ?? EncryptType.blockPixelConfusion;
  }
}

extension ExtEncryptType on EncryptType {
  String get typeName {
    switch (this) {
      case EncryptType.blockPixelConfusion:
        return '1: 方块混淆';
      case EncryptType.rowPixelConfusion:
        return '2: 行像素混淆';
      case EncryptType.pixelConfusion:
        return '3: 像素混淆';
      case EncryptType.picEncryptRowConfusion:
        return '4: 兼容PicEncrypt: 行模式';
      case EncryptType.picEncryptRowColConfusion:
        return '5: 兼容PicEncrypt: 行+列模式';
      case EncryptType.gilbert2dConfusion:
        return '6: 空间填充曲线混淆';
    }
  }
}
