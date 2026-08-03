import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../models/modifier_group.dart';
import 'toggle_field_row.dart';

class ModifierSection extends StatelessWidget {
  final ModifierGroup group;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final int selectedOptionIndex;
  final ValueChanged<int> onOptionSelected;

  const ModifierSection({
    super.key,
    required this.group,
    required this.enabled,
    required this.onEnabledChanged,
    required this.selectedOptionIndex,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToggleFieldRow(
          label: 'Modifier',
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        SizedBox(height: 12.h),
        ...List.generate(group.options.length, (index) {
          final option = group.options[index];
          final selected = index == selectedOptionIndex;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => onOptionSelected(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option.label,
                          style: getTextStyle(
                            fontSize: 16.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.chipInactiveText,
                          ),
                        ),
                        _RadioCircle(selected: selected),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: option.products
                        .map(
                          (product) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product.name,
                                  style: getTextStyle(
                                    fontSize: 16.4,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onboardingBackground,
                                  ),
                                ),
                                Text(
                                  '\$${AppHelperFunctions.getFormattedMoney(product.price)}',
                                  style: getTextStyle(
                                    fontSize: 16.4,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onboardingBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool selected;

  const _RadioCircle({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
