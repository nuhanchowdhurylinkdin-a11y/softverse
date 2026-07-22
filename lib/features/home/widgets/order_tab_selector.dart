import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class OrderTabSelector extends StatelessWidget {
  final bool isOrderSelected;
  final VoidCallback onOrderTap;
  final VoidCallback onTableTap;

  const OrderTabSelector({
    super.key,
    required this.isOrderSelected,
    required this.onOrderTap,
    required this.onTableTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.fieldDivider),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab(context, 'Order', isOrderSelected, onOrderTap)),
          Expanded(child: _buildTab(context, 'Table', !isOrderSelected, onTableTap)),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11.r),
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                )
              : null,
        ),
        child: Text(
          label,
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.onboardingBackground,
          ),
        ),
      ),
    );
  }
}
