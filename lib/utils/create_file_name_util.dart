import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CreateFileNameUtil {
  static String timeName({
    DateTime? dateTime,
    bool enableRandom = true,
  }) {
    dateTime ??= DateTime.now();
    DateFormat dateFormat = DateFormat('yyyyMMdd_HHmmss_SSSSSS');
    String formattedDate = dateFormat.format(dateTime);

    if (enableRandom) {
      String randomSuffix = _generateRandomString();
      String uniqueTimestamp = '${formattedDate}_$randomSuffix';
      return uniqueTimestamp;
    } else {
      return formattedDate;
    }
  }

  static String timeUidName({DateTime? dateTime}) {
    dateTime ??= DateTime.now();
    DateFormat dateFormat = DateFormat('yyyyMMdd_HHmmss_SSSSSS');
    String formattedDate = dateFormat.format(dateTime);
    return '${formattedDate}_${const Uuid().v4()}';
  }
}

String _generateRandomString() {
  final random = math.Random();
  return random.nextInt(1000000).toString().padLeft(6, '0');
}
