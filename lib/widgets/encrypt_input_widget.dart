import 'package:flutter/material.dart';
import 'package:picencrypt/pages/home_page/bean/encrypt_type.dart';
import 'package:picencrypt/pages/home_page/bean/input_format_bean.dart';

class EncryptInputWidget extends StatelessWidget {
  const EncryptInputWidget({
    super.key,
    required this.encryptType,
    this.focusNode,
    required this.controller,
    required this.inputFormatBean,
    required this.onChanged,
    required this.onSubmitted,
  });

  final EncryptType encryptType;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final InputFormatBean inputFormatBean;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: encryptType == EncryptType.gilbert2dConfusion,
      child: Opacity(
        opacity: encryptType == EncryptType.gilbert2dConfusion ? 0.3 : 1.0,
        child: Row(
          children: [
            const Text('密钥(Encryption key)：'),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                keyboardType: inputFormatBean.keyboardType,
                inputFormatters: inputFormatBean.formats,
                decoration: InputDecoration(
                  labelText: inputFormatBean.labelText,
                  border: const OutlineInputBorder(),
                ),
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
