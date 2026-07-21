import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconBubble extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final double size;
  final double imageSize;
  final double borderRadius;

  const IconBubble({
    super.key,
    required this.imagePath,
    required this.backgroundColor,
    this.size = 82,
    this.imageSize = 64,
    this.borderRadius = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      alignment: Alignment.center,
      child: Image.asset(imagePath, width: imageSize.w, height: imageSize.w),
    );
  }
}
