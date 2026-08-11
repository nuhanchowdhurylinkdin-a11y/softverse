import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/product_image.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../controller/customer_controller.dart';
import '../../models/customer_model.dart';
import '../../widgets/customer_detail_row.dart';

class ViewCustomerScreen extends GetView<CustomerController> {
  const ViewCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final customers = controller.customers;
      final customer = controller.customer.value;
      final showDetails =
          controller.showDetails.value &&
          (customer.id.isNotEmpty || customer.name.isNotEmpty);

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          toolbarHeight: 55.h,
          leading: IconButton(
            onPressed: showDetails ? controller.showList : Get.back,
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
            showDetails
                ? customer.name.isEmpty
                      ? 'Unnamed Customer'
                      : customer.name
                : 'Customers',
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          actions: [
            if (showDetails)
              IconButton(
                onPressed: controller.openEdit,
                icon: Icon(Iconsax.edit_2, color: Colors.white, size: 26.sp),
              )
            else
              IconButton(
                onPressed: controller.openAddCustomer,
                icon: Icon(Iconsax.user_add, color: Colors.white, size: 26.sp),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: controller.fetchCustomers,
            child: showDetails
                ? _CustomerDetails(customer: customer)
                : customers.isEmpty && !controller.isLoading.value
                ? ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      SizedBox(height: 160.h),
                      Icon(
                        Iconsax.user,
                        size: 58.sp,
                        color: AppColors.chipInactiveText,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No customer found.',
                        textAlign: TextAlign.center,
                        style: getTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onboardingBackground,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount:
                        customers.length + (controller.isLoading.value ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (controller.isLoading.value && index == 0) {
                        return const LinearProgressIndicator(minHeight: 2);
                      }
                      final item =
                          customers[index -
                              (controller.isLoading.value ? 1 : 0)];
                      return _CustomerTile(customer: item);
                    },
                  ),
          ),
        ),
      );
    });
  }
}

class _CustomerTile extends GetView<CustomerController> {
  final CustomerModel customer;

  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final selected = controller.customer.value.id == customer.id;

    return Material(
      color: selected ? AppColors.chipBackground : Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => controller.openDetails(customer),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              ProductImage(
                imageUrl: customer.imageUrl,
                size: 52,
                borderRadius: 26,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name.isEmpty
                          ? 'Unnamed Customer'
                          : customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle(
                        fontSize: 16.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle(
                        fontSize: 13.5,
                        color: AppColors.chipInactiveText,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected)
                    const Icon(Icons.check, color: AppColors.primary),
                  IconButton(
                    onPressed: () {
                      controller.selectCustomer(customer);
                      controller.openEdit();
                    },
                    icon: Icon(Iconsax.edit_2, size: 22.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    if (customer.phone.isNotEmpty) return customer.phone;
    if (customer.email.isNotEmpty) return customer.email;
    if (customer.customerCode.isNotEmpty) return customer.customerCode;
    return 'No contact info';
  }
}

class _CustomerDetails extends GetView<CustomerController> {
  final CustomerModel customer;

  const _CustomerDetails({required this.customer});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
            customer.name.isEmpty ? 'Unnamed Customer' : customer.name,
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
          CustomerDetailRow(
            icon: Iconsax.dollar_circle,
            text:
                'Credit Limit: \$${AppHelperFunctions.getFormattedMoney(customer.creditLimit)}',
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
    );
  }
}
