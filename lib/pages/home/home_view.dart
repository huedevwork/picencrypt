import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picencrypt/gen/assets.gen.dart';
import 'package:picencrypt/widgets/ui_image_view.dart';

import 'bean/encrypt_type.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return IgnorePointer(
        ignoring: controller.isPicking.value,
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
                  /// 模式选择
                  _modeView(controller),
                  const SizedBox(height: 10),

                  /// 密钥
                  _encryptionView(controller),
                  const SizedBox(height: 10),

                  /// 设置效果
                  _effectView(controller),
                  const SizedBox(height: 10),

                  /// 图片显示
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
                            return UiImageView(image: controller.uiImage.value);
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: controller.onJumpGithub,
                        child: Image.asset(
                          Assets.images.githubMarkWhite.path,
                          width: 20,
                          height: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Version ${controller.packageInfo.value?.version}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                return controller.uiImage.value == null
                    ? const SizedBox()
                    : FloatingActionButton(
                        onPressed: () => controller.onSaveImage(),
                        tooltip: '保存图片',
                        backgroundColor: Colors.white,
                        enableFeedback: true,
                        child: const Icon(Icons.save),
                      );
              }),
              const SizedBox(width: 20),
              Obx(() {
                return controller.isPicking.value
                    ? const SizedBox()
                    : FloatingActionButton(
                        onPressed: () => controller.onSelectImage(),
                        tooltip: '导入图片',
                        backgroundColor: Colors.white,
                        enableFeedback: true,
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
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.black),
      child: LayoutBuilder(
        builder: (_, constraints) {
          double spacing = 5.0;
          double allInterval = (length - 1) * spacing;
          double width = (constraints.maxWidth - allInterval) / length;
          Size maximumSize = Size.fromWidth(width);
          return Obx(() {
            return Wrap(
              spacing: spacing,
              children: [
                CustomButton(
                  onPressed: c.uiImage.value == null ? null : c.onObfuscate,
                  maximumSize: maximumSize,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        '混淆',
                        style: TextStyle(color: Colors.black),
                      ),
                      AutoSizeText(
                        '(Encrypt)',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  onPressed: c.uiImage.value == null ? null : c.onDecrypt,
                  maximumSize: maximumSize,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        '解混淆',
                        style: TextStyle(color: Colors.black),
                      ),
                      AutoSizeText(
                        '(Decrypt)',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  onPressed: c.uiImage.value == null ? null : c.onReset,
                  maximumSize: maximumSize,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        '还原',
                        style: TextStyle(color: Colors.black),
                      ),
                      AutoSizeText(
                        '(Reset)',
                        style: TextStyle(color: Colors.black),
                      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: child,
    );
  }
}
