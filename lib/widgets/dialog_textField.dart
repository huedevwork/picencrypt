import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picencrypt/pages/home_page/bean/encrypt_type.dart';
import 'package:picencrypt/pages/home_page/bean/input_format_bean.dart';
import 'package:picencrypt/pages/processing_images_page/processing_images_model.dart';

import 'encrypt_input_widget.dart';

class DialogTextField extends StatefulWidget {
  const DialogTextField({super.key, required this.item});

  final EncryptImageBean item;

  @override
  State<DialogTextField> createState() => _DialogTextFieldState();
}

class _DialogTextFieldState extends State<DialogTextField> {
  // 禁止输入空格
  final _disableSpaceFormat = FilteringTextInputFormatter.deny(RegExp(r'\s'));

  // 允许数字和小数点
  final _floatFormat = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

  // 最大长度限制 - 字符
  final _lengthAnyStrFormat = LengthLimitingTextInputFormatter(30);

  // 最大长度限制 - 浮点
  final _lengthFloatRangeFormat = LengthLimitingTextInputFormatter(8);

  String _anyStrKey = '0.666';
  double _floatRangeKey = 0.666;

  TextEditingController textController = TextEditingController();
  late InputFormatBean inputFormatBean;

  @override
  void initState() {
    inputFormatBean = widget.item.inputFormatBean;

    bool value1 = widget.item.encryptType == EncryptType.picEncryptRowConfusion;
    bool value2 = widget.item.encryptType == EncryptType.picEncryptRowColConfusion;
    if (value1 || value2) {
      inputFormatBean = InputFormatBean(
        formats: [_disableSpaceFormat, _floatFormat, _lengthFloatRangeFormat],
        keyboardType: TextInputType.number,
        labelText: '范围 0.1 - 0.9 (Range 0.1 - 0.9)',
      );

      textController.text = widget.item.floatRangeKey.toString();
    } else {
      inputFormatBean = InputFormatBean(
        formats: [_disableSpaceFormat, _lengthAnyStrFormat],
        keyboardType: TextInputType.text,
        labelText: '可为任意字符串(Any String)',
      );

      textController.text = widget.item.anyStrKey;
    }
    super.initState();
  }

  /// 检查输入密钥条件
  void onValidateInput(String value) {
    bool value1 = widget.item.encryptType.value == EncryptType.picEncryptRowConfusion;
    bool value2 = widget.item.encryptType.value == EncryptType.picEncryptRowColConfusion;
    if (value1 || value2) {
      if (value.isEmpty) {
        _floatRangeKey = 0.666;

        textController.text = '0.666';
      } else {
        double? temp = double.tryParse(value);
        if (temp == null) {
          _floatRangeKey = 0.666;

          textController.text = '0.666';
        } else {
          _floatRangeKey = temp;
        }
      }
    } else {
      _anyStrKey = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EncryptInputWidget(
              encryptType: widget.item.encryptType,
              controller: textController,
              inputFormatBean: inputFormatBean,
              onChanged: onValidateInput,
              onSubmitted: onValidateInput,
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Get.back(result: widget.item.copyWith(
                  inputFormatBean: inputFormatBean,
                  anyStrKey: _anyStrKey,
                  floatRangeKey: _floatRangeKey,
                ));
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
