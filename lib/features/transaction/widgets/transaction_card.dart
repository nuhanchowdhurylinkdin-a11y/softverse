import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/transaction_record.dart';

class TransactionCard extends StatelessWidget {
  final TransactionRecord transaction;
  final VoidCallback onOpen;
  final VoidCallback onExportPdf;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onOpen,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.cardBorder),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, AppColors.rowGradientEnd],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.companyName,
                    style: getTextStyle(
                      fontSize: 14.6,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authTextDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Invoice : ${transaction.invoiceNumber}',
                    style: getTextStyle(
                      fontSize: 12.8,
                      color: AppColors.onboardingBackground,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    transaction.orderId,
                    style: getTextStyle(
                      fontSize: 10.9,
                      color: AppColors.chipInactiveText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    transaction.dateTime,
                    style: getTextStyle(
                      fontSize: 10.9,
                      color: AppColors.chipInactiveText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: LinearGradient(
                      colors: transaction.paymentType.gradient
                          .map((c) => c.withValues(alpha: 0.2))
                          .toList(),
                    ),
                  ),
                  child: Text(
                    transaction.paymentType.label,
                    style: getTextStyle(
                      fontSize: 12.8,
                      color: transaction.paymentType.textColor,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(34.w, 34.w)),
                  onPressed: onExportPdf,
                  icon: Icon(
                    Iconsax.document_download,
                    size: 20.sp,
                    color: AppColors.onboardingBackground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
