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

class ResetPasswordScreen extends GetView<AuthController> {
  const ResetPasswordScreen({super.key});

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
                const StepProgressIndicator(stepCount: 3, activeIndex: 2),
                SizedBox(height: 64.h),
                Center(
                  child: IconBubble(
                    imagePath: 'assets/icon/lock.png',
                    backgroundColor: AppColors.iconBubbleGrey,
                  ),
                ),
                SizedBox(height: 29.h),
                Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 29.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authTextDark,
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  'It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum.',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 13.7,
                    color: AppColors.mutedText,
                  ),
                ),
                SizedBox(height: 26.h),
                Obx(
                  () => AppTextField(
                    hintText: 'New Password',
                    controller: controller.newPasswordController,
                    obscureText: controller.obscureNewPassword.value,
                    backgroundColor: AppColors.fieldBackground,
                    borderStyle: AppTextFieldBorder.none,
                    borderRadius: 14,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 16.h,
                    ),
                    suffixIcon: IconButton(
                      onPressed: controller.toggleObscureNewPassword,
                      icon: Icon(
                        controller.obscureNewPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Obx(
                  () => AppTextField(
                    hintText: 'Confirm New Password',
                    controller: controller.confirmNewPasswordController,
                    obscureText: controller.obscureConfirmNewPassword.value,
                    backgroundColor: AppColors.fieldBackground,
                    borderStyle: AppTextFieldBorder.none,
                    borderRadius: 14,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 16.h,
                    ),
                    suffixIcon: IconButton(
                      onPressed: controller.toggleObscureConfirmNewPassword,
                      icon: Icon(
                        controller.obscureConfirmNewPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 29.h),
                Obx(
                  () => PrimaryButton(
                    label: 'Reset Password',
                    isLoading: controller.isResetSubmitting.value,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    textColor: Colors.white,
                    height: 55,
                    borderRadius: 14,
                    fontSize: 14.6,
                    onPressed: controller.submitResetPassword,
                  ),
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
