import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class ToggleFieldRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool boxed;

  const ToggleFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.boxed = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: boxed ? AppColors.chipInactiveText : AppColors.onboardingBackground,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.onboardingBackground,
          inactiveTrackColor: AppColors.toggleTrackOff,
          inactiveThumbColor: Colors.white,
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          trackOutlineWidth: const WidgetStatePropertyAll(0),
        ),
      ],
    );

    if (!boxed) return content;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: content,
    );
  }
}
