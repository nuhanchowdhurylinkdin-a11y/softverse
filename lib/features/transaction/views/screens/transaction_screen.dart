import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_nav_drawer.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/transaction_controller.dart';
import '../../widgets/transaction_card.dart';

class TransactionScreen extends GetView<TransactionController> {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppNavDrawer(),
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 55.h,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.posHeaderStart, AppColors.posHeaderEnd],
            ),
          ),
        ),
        titleSpacing: 16.w,
        title: GestureDetector(
          onTap: controller.openFilter,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Transaction',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Iconsax.arrow_down, color: Colors.white, size: 22.sp),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.openNotifications,
            icon: Icon(Iconsax.notification, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.forceSync,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'All Transactions',
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingBackground,
                  ),
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  hintText: 'Search invoice or customer',
                  onChanged: controller.updateSearchQuery,
                  backgroundColor: AppColors.chipBackground,
                  borderStyle: AppTextFieldBorder.none,
                  borderRadius: 12,
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    size: 20.sp,
                    color: AppColors.chipInactiveText,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: controller.filteredTransactions
                        .map(
                          (transaction) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: TransactionCard(
                              transaction: transaction,
                              onOpen: () =>
                                  controller.openTransaction(transaction),
                              onExportPdf: () =>
                                  controller.exportInvoice(transaction),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
