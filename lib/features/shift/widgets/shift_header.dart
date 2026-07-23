import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class ShiftHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClockTap;
  final IconData trailingIcon;

  const ShiftHeader({
    super.key,
    required this.title,
    this.onClockTap,
    this.trailingIcon = Iconsax.clock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 69.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.posHeaderStart, AppColors.posHeaderEnd],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: getTextStyle(
                fontSize: 21.9,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onClockTap != null)
            GestureDetector(
              onTap: onClockTap,
              child: Icon(trailingIcon, color: Colors.white, size: 26.sp),
            ),
        ],
      ),
    );
  }
}
