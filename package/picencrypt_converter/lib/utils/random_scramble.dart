import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

class RandomScrambleUtil {
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
}