import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picencrypt/widgets/ui_image_view.dart';

import 'bean/encrypt_type.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController c = Get.put(HomeController());

    return Obx(() {
      return IgnorePointer(
        ignoring: c.isPicking.value,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, constraints) {
                        return Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Obx(() {
                            return UiImageView(image: c.uiImage.value);
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 模式选择
                  _modeView(c),
                  const SizedBox(height: 20),

                  /// 密钥
                  _encryptionView(c),
                  const SizedBox(height: 20),

                  /// 设置效果
                  _effectView(c),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                return c.uiImage.value == null
                    ? const SizedBox()
                    : FloatingActionButton(
                        onPressed: () => c.onSaveImage(),
                        tooltip: '保存图片',
                        child: const Icon(Icons.save),
                      );
              }),
              const SizedBox(width: 20),
              Obx(() {
                return c.isPicking.value
                    ? const SizedBox()
                    : FloatingActionButton(
                        onPressed: () => c.onSelectImage(),
                        tooltip: '导入图片',
                        child: const Icon(Icons.image),
                      );
              }),
            ],
          ),
        ),
      );
    });
  }

  /// 模式选择
  Widget _modeView(HomeController c) {
    return Row(
      children: [
        const Text('模式(Mode)：'),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Obx(() {
              return DropdownButton<EncryptType>(
                isExpanded: true,
                underline: const SizedBox(),
                value: c.encryptType.value,
                items: EncryptType.values.map((e) {
                  return DropdownMenuItem<EncryptType>(
                    value: e,
                    child: Center(child: Text(e.typeName)),
                  );
                }).toList(),
                onChanged: (EncryptType? value) {
                  if (value != null) {
                    c.onUpdateEncryptType(value);
                  }
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  /// 密钥
  Widget _encryptionView(HomeController c) {
    return Row(
      children: [
        const Text('密钥(Encryption key)：'),
        Expanded(
          child: Obx(() {
            return TextField(
              controller: c.textController.value,
              keyboardType: c.inputFormatBean.value.keyboardType,
              inputFormatters: c.inputFormatBean.value.formats,
              decoration: InputDecoration(
                labelText: c.inputFormatBean.value.labelText,
                border: const OutlineInputBorder(),
              ),
              onChanged: c.onValidateInput,
              onSubmitted: c.onValidateInput,
            );
          }),
        ),
      ],
    );
  }

  /// 设置效果
  Widget _effectView(HomeController c) {
    int length = 3;
    final ThemeData theme = Theme.of(Get.context!);
    return DefaultTextStyle(
      style: TextStyle(color: Colors.black),
      child: LayoutBuilder(
        builder: (_, constraints) {
          double spacing = 10.0;
          double allInterval = (length - 1) * spacing;
          double width = (constraints.maxWidth - allInterval) / length;
          Size maximumSize = Size.fromWidth(width);
          return Obx(() {
            return Wrap(
              spacing: spacing,
              children: [
                CustomButton(
                  backgroundColor: const Color(0xff28a745),
                  onPressed: c.uiImage.value == null ? null : c.onObfuscate,
                  maximumSize: maximumSize,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('混淆'),
                      Text('(Encrypt)'),
                    ],
                  ),
                ),
                CustomButton(
                  backgroundColor: const Color(0xffffc107),
                  onPressed: c.uiImage.value == null ? null : c.onDecrypt,
                  maximumSize: maximumSize,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('解混淆'),
                      Text('(Decrypt)'),
                    ],
                  ),
                ),
                CustomButton(
                  backgroundColor: const Color(0xffdc3545),
                  onPressed: c.uiImage.value == null ? null : c.onReset,
                  maximumSize: maximumSize,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('还原'),
                      Text('(Reset)'),
                    ],
                  ),
                ),
              ],
            );
          });
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
      ),
      child: child,
    );
  }
}
