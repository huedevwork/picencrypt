import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picencrypt/gen/assets.gen.dart';
import 'package:picencrypt/widgets/encrypt_button_widget.dart';
import 'package:picencrypt/widgets/encrypt_input_widget.dart';
import 'package:picencrypt/widgets/encrypt_mode_widget.dart';
import 'package:picencrypt/widgets/ui_image_view.dart';

import 'controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
        floatingActionButton: floatingActionButtonView(),
        body: SafeArea(child: mainView()),
      ),
    );
  }

  Widget floatingActionButtonView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          return controller.isPicking.value
              ? const SizedBox()
              : FloatingActionButton(
                  heroTag: 'onSelectImage',
                  onPressed: controller.onSelectImage,
                  tooltip: '导入图片',
                  backgroundColor: Colors.white,
                  enableFeedback: true,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image),
                      AutoSizeText(
                        '导入图片',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
        }),
        const SizedBox(height: 10),
        Obx(() {
          return controller.uiImage.value == null
              ? const SizedBox()
              : Column(
                children: [
                  FloatingActionButton(
                      heroTag: 'onSaveImage',
                      onPressed: controller.onSaveImage,
                      tooltip: '保存图片',
                      backgroundColor: Colors.white,
                      enableFeedback: true,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          AutoSizeText(
                            '保存',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'onClear',
                    onPressed: controller.onClear,
                    tooltip: '清除',
                    backgroundColor: Colors.white,
                    enableFeedback: true,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever),
                        AutoSizeText(
                          '清除',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
        }),
      ],
    );
  }

  Widget mainView() {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        bool isLandscapeScreen = orientation == Orientation.landscape;
        bool isTablet = Get.context?.isTablet ?? false;
        if (isTablet && isLandscapeScreen) {
          return tabletLayoutView();
        } else {
          return defaultLayoutView();
        }
      },
    );
  }

  Widget tabletLayoutView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (controller.focusNode.value.hasFocus) {
          controller.focusNode.value.unfocus();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        /// 模式选择
                        Obx(() {
                          return EncryptModeWidget(
                            encryptType: controller.encryptType.value,
                            onChanged: (value) {
                              controller.onUpdateEncryptType(value);
                            },
                          );
                        }),
                        const SizedBox(height: 10),

                        /// 密钥
                        Obx(() {
                          return EncryptInputWidget(
                            encryptType: controller.encryptType.value,
                            focusNode: controller.focusNode.value,
                            controller: controller.textController.value,
                            inputFormatBean: controller.inputFormatBean.value,
                            onChanged: controller.onValidateInput,
                            onSubmitted: controller.onValidateInput,
                          );
                        }),
                        const SizedBox(height: 10),

                        /// 设置效果
                        Obx(() {
                          return EncryptButtonWidget(
                            ignoring: controller.uiImage.value == null,
                            onEncrypt: controller.onEncrypt,
                            onDecrypt: controller.onDecrypt,
                            onReset: controller.onReset,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

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
                            return GestureDetector(
                              onTap: controller.uiImage.value == null
                                  ? null
                                  : controller.onOpenExamineImage,
                              child: UiImageView(
                                image: controller.uiImage.value,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            versionView(),
          ],
        ),
      ),
    );
  }

  Widget defaultLayoutView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (controller.focusNode.value.hasFocus) {
          controller.focusNode.value.unfocus();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            /// 模式选择
            Obx(() {
              return EncryptModeWidget(
                encryptType: controller.encryptType.value,
                onChanged: (value) {
                  controller.onUpdateEncryptType(value);
                },
              );
            }),
            const SizedBox(height: 10),

            /// 密钥
            Obx(() {
              return EncryptInputWidget(
                encryptType: controller.encryptType.value,
                focusNode: controller.focusNode.value,
                controller: controller.textController.value,
                inputFormatBean: controller.inputFormatBean.value,
                onChanged: controller.onValidateInput,
                onSubmitted: controller.onValidateInput,
              );
            }),
            const SizedBox(height: 10),

            /// 设置效果
            Obx(() {
              return EncryptButtonWidget(
                ignoring: controller.uiImage.value == null,
                onEncrypt: controller.onEncrypt,
                onDecrypt: controller.onDecrypt,
                onReset: controller.onReset,
              );
            }),
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
                      return GestureDetector(
                        onTap: controller.uiImage.value == null
                            ? null
                            : controller.onOpenExamineImage,
                        child: UiImageView(
                          image: controller.uiImage.value,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            versionView(),
          ],
        ),
      ),
    );
  }

  Widget versionView() {
    return Obx(() {
      String? version = controller.packageInfo.value?.version;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: controller.onJumpGithub,
            onLongPress: controller.onExportLogs,
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
                // onLongPress: controller.onSetSAFDirectory,
                child: Text(
                  'Version $version',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
