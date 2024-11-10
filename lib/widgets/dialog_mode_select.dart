import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picencrypt/pages/home_page/bean/encrypt_type.dart';

import 'encrypt_mode_widget.dart';

class DialogModeSelect extends StatefulWidget {
  const DialogModeSelect({super.key, required this.encryptType});

  final EncryptType encryptType;

  @override
  State<DialogModeSelect> createState() => _DialogModeSelectState();
}

class _DialogModeSelectState extends State<DialogModeSelect> {
  late EncryptType encryptType = widget.encryptType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EncryptModeWidget(
              encryptType: encryptType,
              onChanged: (value) {
                setState(() {
                  encryptType = value;
                });
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Get.back(result: encryptType);
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
