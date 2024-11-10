import 'package:flutter/services.dart';

class InputFormatBean {
  InputFormatBean({
    required this.formats,
    required this.keyboardType,
    required this.labelText,
  });

  late List<TextInputFormatter> formats;
  late TextInputType keyboardType;
  late String labelText;
}
