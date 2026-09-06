import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/transaction_record.dart';

/// Sentinel returned when the user explicitly picks "All", so it can be told
/// apart from a `null` result (sheet dismissed without choosing anything).
const Object kTransactionFilterAll = Object();

/// Returns [kTransactionFilterAll], a [PaymentType], or `null` if dismissed
/// without a selection.
Future<Object?> showTransactionFilterSheet({
  required BuildContext context,
  required PaymentType? selected,
}) {
  return showModalBottomSheet<Object?>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Text(
              'Filter Transactions',
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingBackground,
              ),
            ),
            SizedBox(height: 8.h),
            _FilterTile(
              label: 'All',
              isSelected: selected == null,
              onTap: () => Navigator.of(context).pop(kTransactionFilterAll),
            ),
            for (final option in PaymentType.values)
              _FilterTile(
                label: option.label,
                isSelected: option == selected,
                onTap: () => Navigator.of(context).pop(option),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      );
    },
  );
}

class _FilterTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: getTextStyle(
          fontSize: 14.6,
          color: isSelected
              ? AppColors.onboardingBackground
              : AppColors.authTextDark,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.onboardingBackground, size: 20.sp)
          : null,
      onTap: onTap,
    );
  }
}
