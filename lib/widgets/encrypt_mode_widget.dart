import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:picencrypt/pages/home_page/bean/encrypt_type.dart';

class EncryptModeWidget extends StatelessWidget {
  const EncryptModeWidget({
    super.key,
    required this.encryptType,
    this.onChanged,
  });

  final EncryptType encryptType;
  final ValueChanged<EncryptType>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('模式'),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<EncryptType>(
              isExpanded: true,
              underline: const SizedBox(),
              value: encryptType,
              items: EncryptType.values.map((e) {
                return DropdownMenuItem<EncryptType>(
                  value: e,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(e.typeName, maxLines: 1),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (EncryptType? value) {
                if (value != null) {
                  onChanged?.call(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
