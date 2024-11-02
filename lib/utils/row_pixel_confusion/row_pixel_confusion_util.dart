import 'package:image/image.dart' as img;
import 'package:picencrypt/utils/pic_encrypt_util.dart';

class RowPixelConfusionUtil {
  static img.Image encodeImg({
    required img.Image image,
    required String key,
  }) {
    int width = image.width;
    int height = image.height;
    List<int> xl = PicEncryptUtil.randomScramble(key: key, arrLength: width);
    // List<int> yl = PicEncryptUtil.randomScramble(key: key, arrLength: hit);

    img.Image rawImage = img.Image(width: width, height: height);
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        int m = i, n = j;
        m = (xl[n % width] + m) % width;
        m = xl[m];
        img.Pixel pixel = image.getPixel(m, n);
        rawImage.setPixel(i, j, pixel);
      }
    }
    return rawImage;
  }

  static img.Image decodeImg({
    required img.Image image,
    required String key,
  }) {
    int width = image.width;
    int height = image.height;
    List<int> xl = PicEncryptUtil.randomScramble(key: key, arrLength: width);
    // List<int> yl = PicEncryptUtil.randomScramble(key: key, arrLength: hit);

    img.Image rawImage = img.Image(width: width, height: height);
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        int m = i, n = j;
        m = (xl[n % width] + m) % width;
        m = xl[m];
        img.Pixel pixel = image.getPixel(i, j);
        rawImage.setPixel(m, n, pixel);
      }
    }
    return rawImage;
  }
}
