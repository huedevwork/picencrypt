import 'package:image/image.dart' as img;

class PicEncryptRowColConfusionUtil {
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
    double x = key;

    img.Image rowImage = img.Image(width: width, height: height);
    img.Image colImage = img.Image(width: width, height: height);

    for (int j = 0; j < height; j++) {
      List<List<double>> doubleArrayAddress = _produceLogistic(x, width);
      x = doubleArrayAddress[width - 1][0];
      doubleArrayAddress.sort((a, b) => a[0].compareTo(b[0]));
      List<int> intArrayAddress = doubleArrayAddress.map((a) {
        return a[1].toInt();
      }).toList();
      for (int i = 0; i < width; i++) {
        int m = intArrayAddress[i];
        img.Pixel pixel = image.getPixel(m, j);
        rowImage.setPixel(i, j, pixel);
      }
    }

    x = key;
    for (int i = 0; i < width; i++) {
      List<List<double>> doubleArrayAddress = _produceLogistic(x, height);
      x = doubleArrayAddress[height - 1][0];
      doubleArrayAddress.sort((a, b) => a[0].compareTo(b[0]));
      List<int> intArrayAddress = doubleArrayAddress.map((a) {
        return a[1].toInt();
      }).toList();
      for (int j = 0; j < height; j++) {
        int n = intArrayAddress[j];
        img.Pixel pixel = rowImage.getPixel(i, n);
        colImage.setPixel(i, j, pixel);
      }
    }

    return colImage;
  }

  static img.Image decodeImg({
    required img.Image image,
    required double key,
  }) {
    int width = image.width;
    int height = image.height;
    double x = key;

    img.Image rowImage = img.Image(width: width, height: height);
    img.Image colImage = img.Image(width: width, height: height);

    for (int i = 0; i < width; i++) {
      List<List<double>> doubleArrayAddress = _produceLogistic(x, height);
      x = doubleArrayAddress[height - 1][0];
      doubleArrayAddress.sort((a, b) => a[0].compareTo(b[0]));
      List<int> intArrayAddress = doubleArrayAddress.map((a) {
        return a[1].toInt();
      }).toList();
      for (int j = 0; j < height; j++) {
        int n = intArrayAddress[j];
        img.Pixel pixel = image.getPixel(i, j);
        rowImage.setPixel(i, n, pixel);
      }
    }

    x = key;
    for (int j = 0; j < height; j++) {
      List<List<double>> doubleArrayAddress = _produceLogistic(x, width);
      x = doubleArrayAddress[width - 1][0];
      doubleArrayAddress.sort((a, b) => a[0].compareTo(b[0]));
      List<int> intArrayAddress = doubleArrayAddress.map((a) {
        return a[1].toInt();
      }).toList();
      for (int i = 0; i < width; i++) {
        int m = intArrayAddress[i];
        img.Pixel pixel = rowImage.getPixel(i, j);
        colImage.setPixel(m, j, pixel);
      }
    }

    return colImage;
  }
}
