import 'package:image/image.dart' as img;
import 'package:picencrypt/utils/pic_encrypt_util.dart';

class BlockPixelConfusionUtil {
  static img.Image encodeImg({
    required img.Image image,
    required String key,
    required int sx,
    required int sy,
  }) {
    int width = image.width;
    int height = image.height;
    int ssx, ssy;
    List<int> xl = PicEncryptUtil.randomScramble(key: key, arrLength: sx);
    List<int> yl = PicEncryptUtil.randomScramble(key: key, arrLength: sy);

    while (width % sx > 0) {
      width++;
    }
    while (height % sy > 0) {
      height++;
    }
    ssx = width ~/ sx;
    ssy = height ~/ sy;

    img.Image rawImage = img.Image(width: width, height: height);
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        int m = i;
        int n = j;
        m = (xl[((n ~/ ssy) % sx)] * ssx + m) % width;
        m = xl[m ~/ ssx] * ssx + m % ssx;
        n = (yl[((m ~/ ssx) % sy)] * ssy + n) % height;
        n = yl[n ~/ ssy] * ssy + n % ssy;
        if (m < image.width && n < image.height) {
          img.Pixel pixel = image.getPixel(m, n);
          rawImage.setPixel(i, j, pixel);
        }
      }
    }
    return rawImage;
  }

  static img.Image decodeImg({
    required img.Image image,
    required String key,
    required int sx,
    required int sy,
  }) {
    int width = image.width;
    int height = image.height;
    int ssx, ssy;
    List<int> xl = PicEncryptUtil.randomScramble(key: key, arrLength: sx);
    List<int> yl = PicEncryptUtil.randomScramble(key: key, arrLength: sy);

    while (width % sx > 0) {
      width++;
    }
    while (height % sy > 0) {
      height++;
    }
    ssx = width ~/ sx;
    ssy = height ~/ sy;

    img.Image rawImage = img.Image(width: width, height: height);
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        int m = i;
        int n = j;
        m = (xl[((n ~/ ssy) % sx)] * ssx + m) % width;
        m = xl[m ~/ ssx] * ssx + m % ssx;
        n = (yl[((m ~/ ssx) % sy)] * ssy + n) % height;
        n = yl[n ~/ ssy] * ssy + n % ssy;
        if (i < image.width && j < image.height) {
          img.Pixel pixel = image.getPixel(i, j);
          rawImage.setPixel(m, n, pixel);
        }
      }
    }
    return rawImage;
  }
}
