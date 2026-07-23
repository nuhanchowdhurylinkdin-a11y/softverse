import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class ItemPhotoPicker extends StatelessWidget {
  final VoidCallback onChoosePhoto;
  final VoidCallback onTakePhoto;

  const ItemPhotoPicker({
    super.key,
    required this.onChoosePhoto,
    required this.onTakePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightBorder,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Iconsax.image,
              size: 48.sp,
              color: AppColors.chipInactiveText,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onChoosePhoto,
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.folder,
                        size: 22.sp,
                        color: AppColors.authTextDark,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'CHOOSE PHOTO',
                        style: getTextStyle(
                          fontSize: 16.4,
                          fontWeight: FontWeight.w500,
                          color: AppColors.authTextDark,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.h),
                GestureDetector(
                  onTap: onTakePhoto,
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.camera,
                        size: 22.sp,
                        color: AppColors.authTextDark,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'TAKE PHOTO',
                        style: getTextStyle(
                          fontSize: 16.4,
                          fontWeight: FontWeight.w500,
                          color: AppColors.authTextDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
