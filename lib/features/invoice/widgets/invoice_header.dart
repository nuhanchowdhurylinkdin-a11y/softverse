import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class InvoiceHeader extends StatelessWidget {
  final String title;
  final VoidCallback onNotificationTap;
  final VoidCallback onMailTap;
  final VoidCallback onPrintTap;

  const InvoiceHeader({
    super.key,
    required this.title,
    required this.onNotificationTap,
    required this.onMailTap,
    required this.onPrintTap,
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
            onTap: Get.back,
            child: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onNotificationTap,
            child: Icon(Iconsax.notification, color: Colors.white, size: 26.sp),
          ),
          SizedBox(width: 15.w),
          GestureDetector(
            onTap: onMailTap,
            child: Icon(Iconsax.sms, color: Colors.white, size: 26.sp),
          ),
          SizedBox(width: 15.w),
          GestureDetector(
            onTap: onPrintTap,
            child: Icon(Iconsax.printer, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
    );
  }
}
