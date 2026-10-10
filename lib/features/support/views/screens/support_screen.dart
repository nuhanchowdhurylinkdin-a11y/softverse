import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/support_controller.dart';

class SupportScreen extends GetView<SupportController> {
  const SupportScreen({super.key});

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
          'Support',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Text(
              'Frequently asked questions',
              style: getTextStyle(fontSize: 15.2, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              if (controller.isLoadingFaqs.value && controller.faqs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: [
                  for (final faq in controller.faqs)
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          faq.question,
                          style: getTextStyle(
                            fontSize: 14.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Text(
                                faq.answer,
                                style: getTextStyle(
                                  fontSize: 13.6,
                                  color: AppColors.chipInactiveText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
            SizedBox(height: 24.h),
            Text(
              'Contact support',
              style: getTextStyle(fontSize: 15.2, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            AppTextField(
              label: 'Email',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              borderStyle: AppTextFieldBorder.outline,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              label: 'Contact number',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              borderStyle: AppTextFieldBorder.outline,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              label: 'Message',
              hintText: 'Describe the problem',
              controller: controller.messageController,
              maxLines: 5,
              borderStyle: AppTextFieldBorder.outline,
            ),
            SizedBox(height: 20.h),
            Obx(
              () => PrimaryButton(
                label: 'Send',
                isLoading: controller.isSending.value,
                onPressed: controller.submit,
                backgroundColor: AppColors.onboardingBackground,
                textColor: Colors.white,
                height: 52,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
