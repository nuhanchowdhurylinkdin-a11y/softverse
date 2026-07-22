import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/transaction_controller.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/transaction_header.dart';

class TransactionScreen extends GetView<TransactionController> {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TransactionHeader(
              onFilterTap: controller.openFilter,
              onNotificationTap: controller.openNotifications,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'All Transections',
                      style: getTextStyle(
                        fontSize: 16.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...controller.transactions.map(
                      (transaction) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: TransactionCard(
                          transaction: transaction,
                          onOpen: () => controller.openTransaction(transaction),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
