import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/feature_toggle_item.dart';

class FeatureToggleTile extends StatelessWidget {
  final FeatureToggleItem item;
  final bool value;
  final ValueChanged<bool> onChanged;

  const FeatureToggleTile({
    super.key,
    required this.item,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 25.sp, color: AppColors.featureTitle),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: getTextStyle(
                    fontSize: 14.6,
                    fontWeight: FontWeight.w500,
                    color: AppColors.featureTitle,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  style: getTextStyle(
                    fontSize: 12.8,
                    color: AppColors.featureSubtitle,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.toggleTrackOff,
            inactiveThumbColor: Colors.white,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            trackOutlineWidth: const WidgetStatePropertyAll(0),
          ),
        ],
      ),
    );
  }
}
