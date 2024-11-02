import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;
import 'package:picencrypt/utils/row_pixel_confusion/row_pixel_confusion_util.dart';

import 'block_pixel_confusion/block_pixel_confusion_util.dart';
import 'compute_util.dart';
import 'pic_encrypt_row_col_confusion/pic_encrypt_row_col_confusion_util.dart';
import 'pic_encrypt_row_confusion/pic_encrypt_row_confusion_util.dart';
import 'pixel_confusion/pixel_confusion_util.dart';

class PicEncryptUtil {
  static const int _arrLength = 32;

  static List<int> randomScramble({
    required String key,
    int? arrLength,
  }) {
    arrLength ??= _arrLength;

    List<int> arr = List<int>.generate(arrLength, (index) => index);

    for (int i = arrLength - 1; i > 0; i--) {
      String content = key + i.toString();
      var bytes = utf8.encode(content);
      var md5Hash = crypto.md5.convert(bytes);
      String md5Hex = md5Hash.toString().substring(0, 7).toUpperCase();
      int rand = int.parse(md5Hex, radix: 16) % (i + 1);

      int temp = arr[rand];
      arr[rand] = arr[i];
      arr[i] = temp;
    }

    return arr;
  }

  static Future<img.Image?> encodeBlockPixelConfusion({
    required img.Image image,
    required String key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return BlockPixelConfusionUtil.encodeImg(
            image: value,
            key: key,
            sx: _arrLength,
            sy: _arrLength,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> decodeBlockPixelConfusion({
    required img.Image image,
    required String key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return BlockPixelConfusionUtil.decodeImg(
            image: value,
            key: key,
            sx: _arrLength,
            sy: _arrLength,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> encodeRowPixelConfusion({
    required img.Image image,
    required String key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return RowPixelConfusionUtil.encodeImg(
            image: value,
            key: key,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> decodeRowPixelConfusion({
    required img.Image image,
    required String key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return RowPixelConfusionUtil.decodeImg(
            image: value,
            key: key,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> encodePixelConfusion({
    required img.Image image,
    required String key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return PixelConfusionUtil.encodeImg(
            image: value,
            key: key,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> decodePixelConfusion({
    required img.Image image,
    required String key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return PixelConfusionUtil.decodeImg(
            image: value,
            key: key,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> encodePicEncryptRowConfusion({
    required img.Image image,
    required double key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return PicEncryptRowConfusionUtil.encodeImg(
            image: value,
            key: key,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> decodePicEncryptRowConfusion({
    required img.Image image,
    required double key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return PicEncryptRowConfusionUtil.decodeImg(
            image: value,
            key: key,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> encodePicEncryptRowColConfusion({
    required img.Image image,
    required double key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return PicEncryptRowColConfusionUtil.encodeImg(
            image: value,
            key: key,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  static Future<img.Image?> decodePicEncryptRowColConfusion({
    required img.Image image,
    required double key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return PicEncryptRowColConfusionUtil.decodeImg(
            image: value,
            key: key,
          );
        },
      );
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }
}
