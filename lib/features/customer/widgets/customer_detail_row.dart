import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class CustomerDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const CustomerDetailRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = AppColors.onboardingBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22.sp, color: iconColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: getTextStyle(
              fontSize: 16.4,
              color: AppColors.chipInactiveText,
            ),
          ),
        ),
      ],
    );
  }
}
