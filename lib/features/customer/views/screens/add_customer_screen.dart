import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/add_customer_controller.dart';
import '../../widgets/customer_form_field.dart';

class AddCustomerScreen extends GetView<AddCustomerController> {
  const AddCustomerScreen({super.key});

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
          'Create Customer',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: controller.choosePhoto,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      border: Border.all(color: AppColors.cardBorder),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.image,
                      size: 32.sp,
                      color: AppColors.chipInactiveText,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              CustomerFormField(
                label: 'Name',
                controller: controller.nameController,
                hintText: 'Abs Corporation',
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Email',
                controller: controller.emailController,
                hintText: 'abcc@ mail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Phone',
                controller: controller.phoneController,
                hintText: '+8801254452300',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Address',
                controller: controller.addressController,
                hintText: '123,green Avenue',
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'City',
                controller: controller.cityController,
                hintText: 'Dhaka',
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Region',
                controller: controller.regionController,
                hintText: 'Bangladesh',
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Postal Code',
                controller: controller.postalCodeController,
                hintText: '1234',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Country',
                controller: controller.countryController,
                hintText: 'Bangladesh',
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Customer code',
                controller: controller.customerCodeController,
                hintText: 'CUS-10001',
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Credit Limit',
                controller: controller.creditLimitController,
                hintText: '18,000.00',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomerFormField(
                label: 'Note',
                controller: controller.noteController,
                maxLines: 5,
              ),
              SizedBox(height: 40.h),
              Center(
                child: PrimaryButton(
                  label: 'Save',
                  onPressed: controller.save,
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  textColor: Colors.white,
                  width: 197.w,
                  height: 68,
                  fontSize: 16.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
