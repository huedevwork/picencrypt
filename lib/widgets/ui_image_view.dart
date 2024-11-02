import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class UiImageView extends StatelessWidget {
  const UiImageView({super.key, required this.image});

  final img.Image? image;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('点击下面右边按钮导入图片'),
          Text('点击下面左边按钮保存图片'),
        ],
      );
    } else {
      return LayoutBuilder(
        builder: (_, cot2) {
          double uiImgWidth;
          double uiImgHeight;

          final aspectRatio = image!.width / image!.height;
          if (cot2.maxWidth / cot2.maxHeight > aspectRatio) {
            uiImgWidth = cot2.maxHeight * aspectRatio;
            uiImgHeight = cot2.maxHeight;
          } else if (cot2.maxWidth / cot2.maxHeight < aspectRatio) {
            uiImgWidth = cot2.maxWidth;
            uiImgHeight = cot2.maxWidth / aspectRatio;
          } else {
            final min = math.min(
              cot2.maxWidth,
              cot2.maxHeight,
            );
            uiImgWidth = min;
            uiImgHeight = min;
          }

          final imageData = Uint8List.fromList(img.encodePng(image!));

          return Image.memory(
            imageData,
            width: uiImgWidth,
            height: uiImgHeight,
            fit: BoxFit.contain,
          );
        },
      );
    }
  }
}
