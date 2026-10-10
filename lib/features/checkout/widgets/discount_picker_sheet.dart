import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../../item/models/discount_rule_model.dart';

class DiscountPickerSheet extends StatelessWidget {
  final List<DiscountRuleModel> discounts;
  final String? appliedId;
  final VoidCallback onRemove;

  const DiscountPickerSheet({
    super.key,
    required this.discounts,
    required this.appliedId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.7.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                'Apply discount',
                style: getTextStyle(fontSize: 16.4, fontWeight: FontWeight.w600),
              ),
            ),
            if (discounts.isEmpty)
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  'No discounts yet. Create one under Items > Discounts.',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 14,
                    color: AppColors.chipInactiveText,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: discounts.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final discount = discounts[index];
                    final selected = discount.id == appliedId;
                    final valueLabel = discount.value > 0
                        ? discount.displayValue
                        : 'Enter at checkout';
                    return ListTile(
                      onTap: () => Get.back(result: discount),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(
                          color: selected
                              ? AppColors.onboardingBackground
                              : AppColors.cardBorder,
                        ),
                      ),
                      leading: Icon(Iconsax.tag, size: 20.sp),
                      title: Text(
                        discount.name,
                        style: getTextStyle(
                          fontSize: 14.6,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      subtitle: Text(
                        discount.restrictedAccess
                            ? '$valueLabel · restricted'
                            : valueLabel,
                        style: getTextStyle(
                          fontSize: 12.8,
                          color: AppColors.chipInactiveText,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      trailing: selected
                          ? Icon(
                              Iconsax.tick_circle,
                              color: AppColors.onboardingBackground,
                              size: 20.sp,
                            )
                          : null,
                    );
                  },
                ),
              ),
            if (appliedId != null)
              TextButton(
                onPressed: onRemove,
                child: Text(
                  'Remove discount',
                  style: getTextStyle(fontSize: 14.6, color: AppColors.dangerRed),
                ),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
