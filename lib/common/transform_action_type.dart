import 'package:picencrypt/gen/assets.gen.dart';

enum TransformActionType {
  /// 左右翻转
  flipHorizontal,

  /// 上下翻转
  flipVertical,

  /// 顺时针旋转90度
  rotateClockwise90,
}

extension ExtTransformActionType on TransformActionType {
  String get typeName {
    switch (this) {
      case TransformActionType.flipHorizontal:
        return '左右翻转';
      case TransformActionType.flipVertical:
        return '上下翻转';
      case TransformActionType.rotateClockwise90:
        return '顺时针旋转90度';
    }
  }

  String get svgIcon {
    switch (this) {
      case TransformActionType.flipHorizontal:
        return Assets.images.flipHorizontal;
      case TransformActionType.flipVertical:
        return Assets.images.flipVertical;
      case TransformActionType.rotateClockwise90:
        return Assets.images.rotateClockwise90;
    }
  }
}
