import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class EncryptButtonWidget extends StatelessWidget {
  const EncryptButtonWidget({
    super.key,
    required this.ignoring,
    required this.onEncrypt,
    required this.onDecrypt,
    required this.onReset,
  });

  final bool ignoring;
  final VoidCallback onEncrypt;
  final VoidCallback onDecrypt;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    int length = 3;
    return IgnorePointer(
      ignoring: ignoring,
      child: LayoutBuilder(
        builder: (_, constraints) {
          double spacing = 5.0;
          double allInterval = (length - 1) * spacing;
          double width = (constraints.maxWidth - allInterval) / length;
          Size maximumSize = Size.fromWidth(width);
          return Wrap(
            spacing: spacing,
            children: [
              CustomButton(
                onPressed: onEncrypt,
                maximumSize: maximumSize,
                child: const AutoSizeText(
                  '混淆',
                  style: TextStyle(color: Colors.black),
                  maxLines: 1,
                ),
              ),
              CustomButton(
                onPressed: onDecrypt,
                maximumSize: maximumSize,
                child: const AutoSizeText(
                  '解混淆',
                  style: TextStyle(color: Colors.black),
                  maxLines: 1,
                ),
              ),
              CustomButton(
                onPressed: onReset,
                maximumSize: maximumSize,
                child: const AutoSizeText(
                  '还原',
                  style: TextStyle(color: Colors.black),
                  maxLines: 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.backgroundColor,
    this.onPressed,
    required this.maximumSize,
    required this.child,
  });

  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final Size maximumSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        maximumSize: maximumSize,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: child,
    );
  }
}
