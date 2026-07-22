import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class WalkthroughSlide extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const WalkthroughSlide({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              imagePath,
              width: 300.w,
              height: 242.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 29.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 18.2,
              fontWeight: FontWeight.w500,
              color: AppColors.authTextDark,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: getTextStyle(fontSize: 14.6, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
