import 'dart:math';

import 'package:image/image.dart' as img;

class Gilbert2dConfusionUtil {
  static List<List<int>> _gilbert2d({required int width, required int height}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Width and height must be positive integers.');
    }

    List<List<int>> coordinates = [];

    if (width >= height) {
      _generate2d(
        x: 0,
        y: 0,
        ax: width,
        ay: 0,
        bx: 0,
        by: height,
        coordinates: coordinates,
      );
    } else {
      _generate2d(
        x: 0,
        y: 0,
        ax: 0,
        ay: height,
        bx: width,
        by: 0,
        coordinates: coordinates,
      );
    }

    return coordinates;
  }

  static void _generate2d({
    required int x,
    required int y,
    required int ax,
    required int ay,
    required int bx,
    required int by,
    required List<List<int>> coordinates,
  }) {
    int w = (ax + ay).abs();
    int h = (bx + by).abs();

    int dax = ax.sign;
    int day = ay.sign;
    int dbx = bx.sign;
    int dby = by.sign;

    if (h == 1) {
      for (int i = 0; i < w; i++) {
        coordinates.add([x, y]);
        x += dax;
        y += day;
      }
      return;
    }

    if (w == 1) {
      for (int i = 0; i < h; i++) {
        coordinates.add([x, y]);
        x += dbx;
        y += dby;
      }
      return;
    }

    int ax2 = (ax / 2).floor();
    int ay2 = (ay / 2).floor();
    int bx2 = (bx / 2).floor();
    int by2 = (by / 2).floor();

    int w2 = (ax2 + ay2).abs();
    int h2 = (bx2 + by2).abs();

    if (2 * w > 3 * h) {
      if ((w2 % 2 != 0) && (w > 2)) {
        ax2 += dax;
        ay2 += day;
      }

      _generate2d(
        x: x,
        y: y,
        ax: ax2,
        ay: ay2,
        bx: bx,
        by: by,
        coordinates: coordinates,
      );

      _generate2d(
        x: x + ax2,
        y: y + ay2,
        ax: ax - ax2,
        ay: ay - ay2,
        bx: bx,
        by: by,
        coordinates: coordinates,
      );
    } else {
      if ((h2 % 2 != 0) && (h > 2)) {
        bx2 += dbx;
        by2 += dby;
      }

      _generate2d(
        x: x,
        y: y,
        ax: bx2,
        ay: by2,
        bx: ax2,
        by: ay2,
        coordinates: coordinates,
      );

      _generate2d(
        x: x + bx2,
        y: y + by2,
        ax: ax,
        ay: ay,
        bx: bx - bx2,
        by: by - by2,
        coordinates: coordinates,
      );

      _generate2d(
        x: x + (ax - dax) + (bx2 - dbx),
        y: y + (ay - day) + (by2 - dby),
        ax: -bx2,
        ay: -by2,
        bx: -(ax - ax2),
        by: -(ay - ay2),
        coordinates: coordinates,
      );
    }
  }

  static img.Image transformImage({
    required img.Image image,
    required bool isEncrypt,
  }) {
    final width = image.width;
    final height = image.height;

    final coordinates = _gilbert2d(width: width, height: height);
    final offset = ((sqrt(5) - 1) / 2 * width * height).round();

    img.Image rawImage = img.Image(width: width, height: height);

    for (int i = 0; i < width * height; i++) {
      final oldPos = coordinates[i];

      int newPosIndex;
      if (isEncrypt) {
        newPosIndex = (i + offset) % (width * height);
      } else {
        newPosIndex = (i - offset) % (width * height);
      }

      int index;
      if (newPosIndex < 0) {
        index = newPosIndex + width * height;
      } else {
        index = newPosIndex;
      }

      final newPos = coordinates[index];

      final pixel = image.getPixel(oldPos[0], oldPos[1]);

      rawImage.setPixel(newPos[0], newPos[1], pixel);
    }
    return rawImage;
  }
}
