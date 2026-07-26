import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/product_image.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/customer_controller.dart';
import '../../widgets/customer_detail_row.dart';

class ViewCustomerScreen extends GetView<CustomerController> {
  const ViewCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final customer = controller.customer.value;

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
            customer.name,
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: controller.openAddCustomer,
              icon: Icon(Iconsax.user_add, color: Colors.white, size: 26.sp),
            ),
            IconButton(
              onPressed: controller.openEdit,
              icon: Icon(Iconsax.edit_2, color: Colors.white, size: 26.sp),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ProductImage(
                    imageUrl: customer.imageUrl,
                    size: 80,
                    borderRadius: 40,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  customer.name,
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 21.9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingBackground,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomerDetailRow(icon: Iconsax.sms, text: customer.email),
                SizedBox(height: 16.h),
                CustomerDetailRow(icon: Iconsax.call, text: customer.phone),
                SizedBox(height: 16.h),
                CustomerDetailRow(
                  icon: Iconsax.location,
                  text:
                      '${customer.address}, ${customer.city},\n'
                      '${customer.region}, ${customer.postalCode}, ${customer.country}',
                ),
                SizedBox(height: 16.h),
                CustomerDetailRow(
                  icon: Iconsax.personalcard,
                  text: customer.customerCode,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Note',
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingBackground,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 152.h,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    customer.note,
                    style: getTextStyle(
                      fontSize: 16.4,
                      color: AppColors.chipInactiveText,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                CustomerDetailRow(
                  icon: Iconsax.coin,
                  text: '${customer.points.toStringAsFixed(2)} Points',
                ),
                SizedBox(height: 16.h),
                CustomerDetailRow(
                  icon: Iconsax.activity,
                  text: '${customer.visitCount} times Visit',
                ),
                SizedBox(height: 16.h),
                CustomerDetailRow(
                  icon: Iconsax.calendar_1,
                  text: '${customer.lastVisitDate}(Last Visit)',
                ),
                SizedBox(height: 40.h),
                GestureDetector(
                  onTap: controller.redeemPoints,
                  child: Text(
                    'Redeem Points',
                    style: getTextStyle(
                      fontSize: 16.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingBackground,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: controller.viewPurchaseHistory,
                  child: Text(
                    'Purchase History',
                    style: getTextStyle(
                      fontSize: 16.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
