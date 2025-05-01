import 'package:image/image.dart';

class TransformUtil {
  /// 水平翻转图像
  static Image flipHorizontal(Image image) {
    return flip(image, direction: FlipDirection.horizontal);
  }

  /// 垂直翻转图像
  static Image flipVertical(Image image) {
    return flip(image, direction: FlipDirection.vertical);
  }

  /// 旋转图像
  /// [angle] 旋转角度，支持 90、180、270 度
  static Image rotate(Image image, {int angle = 90}) {
    switch (angle) {
      case 90:
        return copyRotate(image, angle: 90);
      case 180:
        return copyRotate(image, angle: 180);
      case 270:
        return copyRotate(image, angle: 270);
      default:
        throw ArgumentError('仅支持 90、180、270 度旋转');
    }
  }
}
