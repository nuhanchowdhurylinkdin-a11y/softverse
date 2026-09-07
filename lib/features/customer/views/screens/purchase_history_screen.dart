import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../controller/customer_controller.dart';
import '../../models/purchase_history_entry.dart';

class PurchaseHistoryScreen extends GetView<CustomerController> {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 55.h,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
        title: Text(
          'Purchase History',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final entries = controller.purchaseHistory;
          if (controller.isLoadingPurchaseHistory.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (entries.isEmpty) {
            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                SizedBox(height: 160.h),
                Icon(
                  Iconsax.receipt_item,
                  size: 58.sp,
                  color: AppColors.chipInactiveText,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No completed purchases yet.',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingBackground,
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: entries.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) =>
                _PurchaseHistoryTile(entry: entries[index]),
          );
        }),
      ),
    );
  }
}

class _PurchaseHistoryTile extends StatelessWidget {
  final PurchaseHistoryEntry entry;

  const _PurchaseHistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isRefunded = entry.status == 'refunded';
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.orderNumber,
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingBackground,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  entry.date == null
                      ? '${entry.itemCount} item(s)'
                      : '${AppHelperFunctions.getFormattedDate(entry.date!, format: 'dd MMM yyyy, hh:mm a')} • ${entry.itemCount} item(s)',
                  style: getTextStyle(
                    fontSize: 13.5,
                    color: AppColors.chipInactiveText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isRefunded ? '-' : ''}\$${AppHelperFunctions.getFormattedMoney(entry.totalAmount)}',
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: isRefunded ? AppColors.dangerRed : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
