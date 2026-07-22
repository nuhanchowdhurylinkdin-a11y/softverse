import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class TransactionHeader extends StatelessWidget {
  final VoidCallback onFilterTap;
  final VoidCallback onNotificationTap;

  const TransactionHeader({
    super.key,
    required this.onFilterTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.h,
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
            onTap: onFilterTap,
            child: Row(
              children: [
                Text(
                  'Transection',
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Iconsax.arrow_down, color: Colors.white, size: 22.sp),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNotificationTap,
            child: Icon(Iconsax.notification, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
    );
  }
}
