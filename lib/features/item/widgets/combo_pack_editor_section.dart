import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../inventory/widgets/toggle_field_row.dart';
import '../models/combo_pack_draft.dart';

class ComboPackEditorSection extends StatelessWidget {
  final bool enabled;
  final List<ComboPackDraft> comboPacks;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onSelectionToggle;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;
  final VoidCallback onAdd;

  const ComboPackEditorSection({
    super.key,
    required this.enabled,
    required this.comboPacks,
    required this.onEnabledChanged,
    required this.onSelectionToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToggleFieldRow(
          label: 'Combo Pack',
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        SizedBox(height: 12.h),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: Icon(Iconsax.add, size: 18.sp, color: AppColors.authLink),
          label: Text(
            'Add combo pack',
            style: getTextStyle(
              fontSize: 14.6,
              fontWeight: FontWeight.w500,
              color: AppColors.authLink,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.cardBorder),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (comboPacks.isEmpty)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              'No combo pack added for this item yet.',
              style: getTextStyle(
                fontSize: 14.6,
                color: AppColors.chipInactiveText,
              ),
            ),
          ),
        ...comboPacks.asMap().entries.map((entry) {
          final index = entry.key;
          final comboPack = entry.value;
          return Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: enabled ? () => onSelectionToggle(index) : null,
                        child: Icon(
                          comboPack.selected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: enabled
                              ? AppColors.authLink
                              : AppColors.chipInactiveText,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          comboPack.label,
                          style: getTextStyle(
                            fontSize: 15.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onboardingBackground,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onEdit(index),
                        icon: Icon(
                          Iconsax.edit_2,
                          size: 18.sp,
                          color: AppColors.authTextDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onDelete(index),
                        icon: Icon(
                          Iconsax.trash,
                          size: 18.sp,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ...comboPack.products.map(
                    (product) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: getTextStyle(
                                fontSize: 14.2,
                                color: AppColors.onboardingBackground,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            '\$${AppHelperFunctions.getFormattedMoney(product.price)}',
                            style: getTextStyle(
                              fontSize: 14.2,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onboardingBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    comboPack.selected
                        ? 'Selected for this item'
                        : 'Saved as draft, not selected',
                    style: getTextStyle(
                      fontSize: 12.8,
                      color: comboPack.selected
                          ? AppColors.authLink
                          : AppColors.chipInactiveText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
