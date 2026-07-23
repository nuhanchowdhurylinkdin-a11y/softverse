import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/radio_circle.dart';
import '../../../core/utils/constants/colors.dart';

class LabeledRadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const LabeledRadioOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioCircle(selected: selected),
          SizedBox(width: 8.w),
          Text(
            label,
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: AppColors.chipInactiveText,
            ),
          ),
        ],
      ),
    );
  }
}
