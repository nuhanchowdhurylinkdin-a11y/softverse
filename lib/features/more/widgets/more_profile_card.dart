import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/primary_button.dart';
import '../../../core/common/widgets/product_image.dart';
import '../../../core/utils/constants/colors.dart';

class MoreProfileCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String role;
  final String posLabel;
  final VoidCallback onSwitchPos;

  const MoreProfileCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.role,
    required this.posLabel,
    required this.onSwitchPos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.billCardStart,
            AppColors.onboardingBackground,
            AppColors.billCardStart,
          ],
          stops: [0, 0.5, 1],
        ),
      ),
      child: Row(
        children: [
          ProductImage(imageUrl: imageUrl, size: 60, borderRadius: 30),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  role,
                  style: getTextStyle(fontSize: 12.8, color: Colors.white),
                ),
              ],
            ),
          ),
          PrimaryButton(
            label: posLabel,
            onPressed: onSwitchPos,
            backgroundColor: Colors.white,
            textColor: AppColors.onboardingBackground,
            width: 120.w,
            height: 40,
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.16,
            borderRadius: 999,
          ),
        ],
      ),
    );
  }
}
