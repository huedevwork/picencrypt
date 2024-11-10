import 'package:flutter/material.dart';

enum ProcessSelectionType {
  /// 单张图片
  single,

  /// 多张图片
  multiple,

  /// 文件夹
  folder;
}

extension ExtProcessSelectionType on ProcessSelectionType {
  String get typeName {
    switch (this) {
      case ProcessSelectionType.single:
        return '单张图片';
      case ProcessSelectionType.multiple:
        return '多张图片';
      case ProcessSelectionType.folder:
        return '文件夹';
    }
  }
}

class ProcessSelectionDialog extends StatelessWidget {
  const ProcessSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ProcessSelectionType.values.map((e) {
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Center(child: Text(e.typeName)),
            onTap: () => Navigator.of(context).pop(e),
          );
        }).toList(),
      ),
    );
  }
}
