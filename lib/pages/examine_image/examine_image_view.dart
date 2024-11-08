import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:photo_view/photo_view.dart';

import 'examine_image_controller.dart';

class ExamineImagePage extends GetView<ExamineImageController> {
  const ExamineImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            PhotoView(
              minScale: PhotoViewComputedScale.contained * 0.9,
              maxScale: PhotoViewComputedScale.covered * 3,
              initialScale: PhotoViewComputedScale.contained,
              imageProvider: MemoryImage(
                img.encodeJpg(controller.uiImage.value),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: InkWell(
                onTap: Get.back,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
