import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picencrypt/pages/home_page/bean/encrypt_type.dart';
import 'package:picencrypt/widgets/encrypt_button_widget.dart';
import 'package:picencrypt/widgets/encrypt_input_widget.dart';
import 'package:picencrypt/widgets/encrypt_mode_widget.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'controller.dart';
import 'model.dart';

class ProcessingImagesPage extends GetView<ProcessingImagesController> {
  const ProcessingImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: !controller.isLoading.value,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
          floatingActionButton: floatingActionButtonView(),
          body: SafeArea(child: mainView()),
        ),
      );
    });
  }

  Widget floatingActionButtonView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        Obx(() {
          return controller.isLoading.value
              ? const SizedBox()
              : Column(
                  children: [
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
                );
        }),
      ],
    );
  }

  Widget mainView() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Obx(() {
            return CircularProgressIndicator(value: controller.progress.value);
          }),
        );
      }

      return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          bool isLandscapeScreen = orientation == Orientation.landscape;
          bool isTablet = Get.context?.isTablet ?? false;

          Widget child;
          if (isTablet && isLandscapeScreen) {
            child = tabletLayoutView();
          } else {
            child = defaultLayoutView();
          }

          return Stack(
            children: [
              child,
              Obx(() {
                bool value = !controller.showBackToTopButton.value;
                return value
                    ? const SizedBox()
                    : Positioned(
                        bottom: 10.0,
                        right: 10.0,
                        child: Tooltip(
                          message: '置顶',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: controller.onBackToTop,
                            child: Container(
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.vertical_align_top),
                            ),
                          ),
                        ),
                      );
              }),
            ],
          );
        },
      );
    });
  }

  Widget tabletLayoutView() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
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
                    inputFormatBean: controller.inputFormatBean.value,
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
            const SizedBox(width: 10),
            Expanded(
              child: ListViewObserver(
                controller: controller.observerController.value,
                onObserve: controller.onObserve,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  controller: controller.scrollController.value,
                  itemCount: controller.uiImages.value.length,
                  itemBuilder: (_, index) {
                    final item = controller.uiImages.value[index];

                    return ImageView(
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget defaultLayoutView() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ListViewObserver(
          controller: controller.observerController.value,
          onObserve: controller.onObserve,
          child: CustomScrollView(
            controller: controller.scrollController.value,
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
                          inputFormatBean: controller.inputFormatBean.value,
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
        ),
      );
    });
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
    Widget imageView() {
      return Expanded(
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

            return Center(
              child: GestureDetector(
                onTap: onOpenImage,
                child: Image.memory(
                  item.renderingData,
                  width: uiImgWidth,
                  height: uiImgHeight,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      );
    }

    Widget controlView() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: onSelectAMode,
            style: OutlinedButton.styleFrom(
              fixedSize: const Size.fromWidth(110),
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
                  fixedSize: const Size.fromWidth(110),
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
              fixedSize: const Size.fromWidth(110),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const AutoSizeText(
              '混淆',
              style: TextStyle(color: Colors.black),
              maxLines: 1,
            ),
          ),
          OutlinedButton(
            onPressed: onDecrypt,
            style: OutlinedButton.styleFrom(
              fixedSize: const Size.fromWidth(110),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const AutoSizeText(
              '解混淆',
              style: TextStyle(color: Colors.black),
              maxLines: 1,
            ),
          ),
          OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              fixedSize: const Size.fromWidth(110),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const AutoSizeText(
              '还原',
              style: TextStyle(color: Colors.black),
              maxLines: 1,
            ),
          ),
          OutlinedButton(
            onPressed: onSave,
            style: OutlinedButton.styleFrom(
              fixedSize: const Size.fromWidth(110),
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
      );
    }

    return Container(
      height: 350,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          imageView(),
          const SizedBox(width: 10),
          controlView(),
        ],
      ),
    );
  }
}
