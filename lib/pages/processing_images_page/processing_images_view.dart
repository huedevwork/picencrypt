import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picencrypt/pages/home_page/bean/encrypt_type.dart';
import 'package:picencrypt/widgets/encrypt_button_widget.dart';
import 'package:picencrypt/widgets/encrypt_input_widget.dart';
import 'package:picencrypt/widgets/encrypt_mode_widget.dart';

import 'processing_images_controller.dart';
import 'processing_images_model.dart';

class ProcessingImagesPage extends GetView<ProcessingImagesController> {
  const ProcessingImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'goBack',
            onPressed: Get.back,
            tooltip: '返回上一级页面',
            backgroundColor: Colors.white,
            enableFeedback: true,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back),
                AutoSizeText(
                  '返回',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'onAllSave',
            onPressed: controller.onAllSave,
            tooltip: '保存列表所有图片',
            backgroundColor: Colors.white,
            enableFeedback: true,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save),
                AutoSizeText(
                  '保存列表',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: SafeArea(
        child: Obx(() {
          return controller.init.value
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        snap: true,
                        stretch: true,
                        floating: true,
                        expandedHeight: 180.0,
                        flexibleSpace: Material(
                          color: Theme.of(Get.context!).scaffoldBackgroundColor,
                          child: FlexibleSpaceBar(
                            background: Column(
                              children: [
                                /// 模式选择
                                EncryptModeWidget(
                                  encryptType: controller.encryptType.value,
                                  onChanged: (value) {
                                    controller.onUpdateAllEncryptType(value);
                                  },
                                ),
                                const SizedBox(height: 10),

                                /// 密钥
                                EncryptInputWidget(
                                  encryptType: controller.encryptType.value,
                                  focusNode: controller.focusNode.value,
                                  controller: controller.textController.value,
                                  inputFormatBean:
                                      controller.inputFormatBean.value,
                                  onChanged: controller.onAllValidateInput,
                                  onSubmitted: controller.onAllValidateInput,
                                ),
                                const SizedBox(height: 10),

                                /// 设置效果
                                EncryptButtonWidget(
                                  ignoring: false,
                                  onEncrypt: controller.onAllEncrypt,
                                  onDecrypt: controller.onAllDecrypt,
                                  onReset: controller.onAllReset,
                                ),
                              ],
                            ),
                          ),
                        ),
                        automaticallyImplyLeading: false,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = controller.uiImages.value[index];

                            bool v = index == controller.uiImages.value.length;
                            return Padding(
                              padding: EdgeInsets.only(bottom: v ? 0 : 10),
                              child: ImageView(
                                item: item,
                                onSelectAMode: () {
                                  controller.setChildEncryptTypeDialog(index);
                                },
                                onSetKey: () {
                                  controller.setChildValidateInputDialog(index);
                                },
                                onEncrypt: () {
                                  controller.onChildEncrypt(index);
                                },
                                onDecrypt: () {
                                  controller.onChildDecrypt(index);
                                },
                                onReset: () {
                                  controller.onChildReset(index);
                                },
                                onSave: () {
                                  controller.onChildSave(index);
                                },
                                onOpenImage: () {
                                  controller.onOpenExamineImage(index);
                                },
                              ),
                            );
                          },
                          childCount: controller.uiImages.value.length,
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  const ImageView({
    super.key,
    required this.item,
    required this.onSelectAMode,
    required this.onSetKey,
    required this.onEncrypt,
    required this.onDecrypt,
    required this.onReset,
    required this.onSave,
    this.onOpenImage,
  });

  final EncryptImageBean item;
  final VoidCallback onSelectAMode;
  final VoidCallback onSetKey;
  final VoidCallback onEncrypt;
  final VoidCallback onDecrypt;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback? onOpenImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (_, cot) {
                double uiImgWidth;
                double uiImgHeight;

                final aspectRatio = item.image.width / item.image.height;
                if (cot.maxWidth / cot.maxHeight > aspectRatio) {
                  uiImgWidth = cot.maxHeight * aspectRatio;
                  uiImgHeight = cot.maxHeight;
                } else if (cot.maxWidth / cot.maxHeight < aspectRatio) {
                  uiImgWidth = cot.maxWidth;
                  uiImgHeight = cot.maxWidth / aspectRatio;
                } else {
                  final min = math.min(
                    cot.maxWidth,
                    cot.maxHeight,
                  );
                  uiImgWidth = min;
                  uiImgHeight = min;
                }

                return GestureDetector(
                  onTap: onOpenImage,
                  child: Image.memory(
                    item.renderingData,
                    width: uiImgWidth,
                    height: uiImgHeight,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: onSelectAMode,
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromWidth(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AutoSizeText(
                      '模式选择',
                      style: TextStyle(color: Colors.black),
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      '模式: ${item.encryptType.value}',
                      style: const TextStyle(color: Colors.black),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                ignoring: item.encryptType == EncryptType.gilbert2dConfusion,
                child: Opacity(
                  opacity: item.encryptType == EncryptType.gilbert2dConfusion
                      ? 0.3
                      : 1.0,
                  child: OutlinedButton(
                    onPressed: onSetKey,
                    style: OutlinedButton.styleFrom(
                      fixedSize: const Size.fromWidth(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AutoSizeText(
                          '密钥',
                          style: TextStyle(color: Colors.black),
                          maxLines: 1,
                        ),
                        AutoSizeText(
                          '${[
                            EncryptType.picEncryptRowConfusion,
                            EncryptType.picEncryptRowColConfusion
                          ].contains(item.encryptType) ? item.floatRangeKey : item.anyStrKey}',
                          style: const TextStyle(color: Colors.black),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onEncrypt,
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromWidth(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      '混淆',
                      style: TextStyle(color: Colors.black),
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      '(Encrypt)',
                      style: TextStyle(color: Colors.black),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onDecrypt,
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromWidth(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      '解混淆',
                      style: TextStyle(color: Colors.black),
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      '(Decrypt)',
                      style: TextStyle(color: Colors.black),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromWidth(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      '还原',
                      style: TextStyle(color: Colors.black),
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      '(Reset)',
                      style: TextStyle(color: Colors.black),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onSave,
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromWidth(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const AutoSizeText(
                  '保存',
                  style: TextStyle(color: Colors.black),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
