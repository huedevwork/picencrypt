import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:picencrypt/pages/home_page/bean/encrypt_type.dart';
import 'package:picencrypt/pages/home_page/bean/input_format_bean.dart';

class EncryptImageBean {
  const EncryptImageBean({
    required this.image,
    required this.renderingData,
    required this.inputFormatBean,
    this.encryptType = EncryptType.blockPixelConfusion,
    this.anyStrKey = '0.666',
    this.floatRangeKey = 0.666,
  });

  final img.Image image;
  final Uint8List renderingData;
  final InputFormatBean inputFormatBean;
  final EncryptType encryptType;
  final String anyStrKey;
  final double floatRangeKey;

  EncryptImageBean copyWith({
    img.Image? image,
    Uint8List? renderingData,
    InputFormatBean? inputFormatBean,
    EncryptType? encryptType,
    String? anyStrKey,
    double? floatRangeKey,
  }) {
    return EncryptImageBean(
      image: image ?? this.image,
      renderingData: renderingData ?? this.renderingData,
      inputFormatBean: inputFormatBean ?? this.inputFormatBean,
      encryptType: encryptType ?? this.encryptType,
      anyStrKey: anyStrKey ?? this.anyStrKey,
      floatRangeKey: floatRangeKey ?? this.floatRangeKey,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['encryptType'] = encryptType.name;
    data['anyStrKey'] = anyStrKey;
    data['floatRangeKey'] = floatRangeKey;
    return data;
  }
}
