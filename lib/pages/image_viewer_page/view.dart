import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import 'controller.dart';

class ImageViewerPage extends GetView<ImageViewerController> {
  const ImageViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              bool isLandscapeScreen = orientation == Orientation.landscape;
              Axis scrollDirection = isLandscapeScreen ? Axis.horizontal : Axis.vertical;
              return PageView.builder(
                scrollDirection: scrollDirection,
                itemCount: controller.imageBytes.length,
                itemBuilder: (_, index) {
                  var data = controller.imageBytes[index];
                  return PhotoView(
                    minScale: PhotoViewComputedScale.contained * 0.9,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    initialScale: PhotoViewComputedScale.contained,
                    imageProvider: MemoryImage(data),
                  );
                },
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: InkWell(
              onTap: Get.back,
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
