import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picencrypt/gen/assets.gen.dart';
import 'package:picencrypt/router/app_pages.dart';
import 'package:picencrypt/widgets/encrypt_button_widget.dart';
import 'package:picencrypt/widgets/encrypt_input_widget.dart';
import 'package:picencrypt/widgets/encrypt_mode_widget.dart';
import 'package:picencrypt/widgets/ui_image_view.dart';

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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (controller.focusNode.value.hasFocus) {
                  controller.focusNode.value.unfocus();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    /// 模式选择
                    EncryptModeWidget(
                      encryptType: controller.encryptType.value,
                      onChanged: (value) {
                        controller.onUpdateEncryptType(value);
                      },
                    ),
                    // _modeView(controller),
                    const SizedBox(height: 10),

                    /// 密钥
                    EncryptInputWidget(
                      encryptType: controller.encryptType.value,
                      focusNode: controller.focusNode.value,
                      controller: controller.textController.value,
                      inputFormatBean: controller.inputFormatBean.value,
                      onChanged: controller.onValidateInput,
                      onSubmitted: controller.onValidateInput,
                    ),
                    const SizedBox(height: 10),

                    /// 设置效果
                    EncryptButtonWidget(
                      ignoring: controller.uiImage.value == null,
                      onEncrypt: controller.onEncrypt,
                      onDecrypt: controller.onDecrypt,
                      onReset: controller.onReset,
                    ),
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
                            child: GestureDetector(
                              onTap: controller.uiImage.value == null
                                  ? null
                                  : () {
                                      Get.toNamed(
                                        AppRoutes.photoView,
                                        arguments: controller.uiImage.value,
                                      );
                                    },
                              child: UiImageView(
                                image: controller.uiImage.value,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// 版本信息
                    _versionView(controller),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              controller.uiImage.value == null
                  ? const SizedBox()
                  : FloatingActionButton(
                      heroTag: 'onSaveImage',
                      onPressed: controller.onSaveImage,
                      tooltip: '保存图片',
                      backgroundColor: Colors.white,
                      enableFeedback: true,
                      child: const Icon(Icons.save),
                    ),
              const SizedBox(width: 20),
              controller.isPicking.value
                  ? const SizedBox()
                  : FloatingActionButton(
                      heroTag: 'onSelectImage',
                      onPressed: controller.onSelectImage,
                      tooltip: '导入图片',
                      backgroundColor: Colors.white,
                      enableFeedback: true,
                      child: const Icon(Icons.image),
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget _versionView(HomeController c) {
    String? version = controller.packageInfo.value?.version;

    return Row(
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
        Visibility(
          visible: version != null,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
              onLongPress: controller.onSetSAFDirectory,
              child: Text(
                'Version $version',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
