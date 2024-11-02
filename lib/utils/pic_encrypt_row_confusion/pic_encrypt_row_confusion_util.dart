import 'package:image/image.dart' as img;

class PicEncryptRowConfusionUtil {
  static List<List<double>> _produceLogistic(double x1, int n) {
    List<List<double>> l = List.generate(n, (index) => [0.0, 0.0]);
    double x = x1;
    l[0] = [x, 0.0];
    for (int i = 1; i < n; i++) {
      x = 3.9999999 * x * (1 - x);
      l[i] = [x, i.toDouble()];
    }
    return l;
  }

  static img.Image encodeImg({
    required img.Image image,
    required double key,
  }) {
    int width = image.width;
    int height = image.height;
    List<List<double>> doubleArrayAddress = _produceLogistic(key, width);
    doubleArrayAddress.sort((a, b) => a[0].compareTo(b[0]));
    List<int> intArrayAddress = doubleArrayAddress.map((a) {
      return a[1].toInt();
    }).toList();

    img.Image imageData = img.Image(width: width, height: height);
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        int m = intArrayAddress[i];
        img.Pixel pixel = image.getPixel(m, j);
        imageData.setPixel(i, j, pixel);
      }
    }

    return imageData;
  }

  static img.Image decodeImg({
    required img.Image image,
    required double key,
  }) {
    int width = image.width;
    int height = image.height;
    List<List<double>> doubleArrayAddress = _produceLogistic(key, width);
    doubleArrayAddress.sort((a, b) => a[0].compareTo(b[0]));
    List<int> intArrayAddress = doubleArrayAddress.map((a) {
      return a[1].toInt();
    }).toList();

    img.Image imageData = img.Image(width: width, height: height);
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        int m = intArrayAddress[i];
        img.Pixel pixel = image.getPixel(i, j);
        imageData.setPixel(m, j, pixel);
      }
    }

    return imageData;
  }
}
