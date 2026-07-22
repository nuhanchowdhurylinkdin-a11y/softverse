import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class PosAppBar extends StatelessWidget {
  final String title;

  const PosAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
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
          Text(
            title,
            style: getTextStyle(
              fontSize: 21.9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Icon(Iconsax.clock, color: Colors.white, size: 26.sp),
          SizedBox(width: 15.w),
          Icon(Iconsax.notification, color: Colors.white, size: 26.sp),
        ],
      ),
    );
  }
}
