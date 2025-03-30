import 'package:image/image.dart' as img;
import 'package:picencrypt_converter/picencrypt_converter.dart';

import 'compute_util.dart';

class PicEncryptUtil {
  static Future<img.Image?> encodeBlockPixelConfusion({
    required img.Image image,
    required String key,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return BlockPixelConfusionUtil.encodeImg(image: value, key: key);
        },
      );
    } catch (e) {
      rethrow;
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
          return BlockPixelConfusionUtil.decodeImg(image: value, key: key);
        },
      );
    } catch (e) {
      rethrow;
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
          return RowPixelConfusionUtil.encodeImg(image: value, key: key);
        },
      );
    } catch (e) {
      rethrow;
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
          return RowPixelConfusionUtil.decodeImg(image: value, key: key);
        },
      );
    } catch (e) {
      rethrow;
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
          return PixelConfusionUtil.encodeImg(image: value, key: key);
        },
      );
    } catch (e) {
      rethrow;
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
          return PixelConfusionUtil.decodeImg(image: value, key: key);
        },
      );
    } catch (e) {
      rethrow;
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
          return PicEncryptRowConfusionUtil.encodeImg(image: value, key: key);
        },
      );
    } catch (e) {
      rethrow;
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
          return PicEncryptRowConfusionUtil.decodeImg(image: value, key: key);
        },
      );
    } catch (e) {
      rethrow;
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
    } catch (e) {
      rethrow;
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
    } catch (e) {
      rethrow;
    }
  }

  static Future<img.Image?> gilbert2dTransformImage({
    required img.Image image,
    required bool isEncrypt,
  }) async {
    try {
      return await ComputeUtil.handle(
        params: image,
        entryLogic: (img.Image value) {
          return Gilbert2dConfusionUtil.transformImage(
            image: value,
            isEncrypt: isEncrypt,
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
