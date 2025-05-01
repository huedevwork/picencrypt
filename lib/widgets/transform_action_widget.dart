import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:picencrypt/common/transform_action_type.dart';

class TransformActionWidget extends StatelessWidget {
  const TransformActionWidget({super.key, this.mainAxisAlignment, this.onTap});

  final MainAxisAlignment? mainAxisAlignment;
  final ValueChanged<TransformActionType>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.spaceEvenly,
      children: TransformActionType.values.map((e) {
        return GestureDetector(
          onTap: () => onTap?.call(e),
          child: Tooltip(
            message: e.typeName,
            child: SvgPicture.asset(e.svgIcon, width: 20, height: 20),
          ),
        );
      }).toList(),
    );
  }
}

class TransformActionWidgetWrap extends StatelessWidget {
  const TransformActionWidgetWrap({super.key, this.onTap});

  final ValueChanged<TransformActionType>? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Wrap(
          spacing: 5.0,
          children: TransformActionType.values.map((e) {
            return SizedBox(
              width: 100,
              child: GestureDetector(
                onTap: () => onTap?.call(e),
                child: Tooltip(
                  message: e.typeName,
                  child: SvgPicture.asset(e.svgIcon, width: 20, height: 20),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
