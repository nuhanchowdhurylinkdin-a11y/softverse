import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_back_button.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/icon_bubble.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/common/widgets/step_progress_indicator.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/auth_controller.dart';

class ForgetPasswordScreen extends GetView<AuthController> {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 37.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),
                const AppBackButton(),
                SizedBox(height: 29.h),
                const StepProgressIndicator(stepCount: 3, activeIndex: 0),
                SizedBox(height: 64.h),
                Center(
                  child: IconBubble(
                    imagePath: 'assets/icon/mail.png',
                    backgroundColor: AppColors.iconBubbleBlue,
                  ),
                ),
                SizedBox(height: 29.h),
                Text(
                  'Forget Password',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 29.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authTextDark,
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  'It was popularized in the 1960s with the release of Letraset sheets containing Lorem Ipsum.',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 12.8,
                    color: AppColors.mutedText,
                  ),
                ),
                SizedBox(height: 26.h),
                AppTextField(
                  hintText: "Email I'D/ Mobile Number",
                  controller: controller.emailOrMobileController,
                  backgroundColor: AppColors.fieldBackground,
                  borderStyle: AppTextFieldBorder.none,
                  borderRadius: 14,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 16.h,
                  ),
                ),
                SizedBox(height: 29.h),
                PrimaryButton(
                  label: 'Continue',
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  textColor: Colors.white,
                  height: 55,
                  borderRadius: 14,
                  fontSize: 14.6,
                  onPressed: controller.continueForgotPassword,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
