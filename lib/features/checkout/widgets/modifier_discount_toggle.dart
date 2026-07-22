import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../controller/checkout_controller.dart';

class ModifierDiscountToggle extends StatelessWidget {
  final PriceAdjustmentMode mode;
  final VoidCallback onModifierTap;
  final VoidCallback onDiscountTap;

  const ModifierDiscountToggle({
    super.key,
    required this.mode,
    required this.onModifierTap,
    required this.onDiscountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildOption(
          'Modifier',
          mode == PriceAdjustmentMode.modifier,
          onModifierTap,
        ),
        SizedBox(width: 32.w),
        _buildOption(
          'Discount',
          mode == PriceAdjustmentMode.discount,
          onDiscountTap,
        ),
      ],
    );
  }

  Widget _buildOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.authLink : AppColors.chipInactiveText,
              ),
              gradient: selected
                  ? const LinearGradient(
                      colors: [
                        AppColors.checkboxGradientStart,
                        AppColors.checkboxGradientEnd,
                      ],
                    )
                  : null,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: getTextStyle(
              fontSize: 12.8,
              color: AppColors.chipInactiveText,
            ),
          ),
        ],
      ),
    );
  }
}
