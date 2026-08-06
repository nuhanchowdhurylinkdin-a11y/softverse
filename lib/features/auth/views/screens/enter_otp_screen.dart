import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_back_button.dart';
import '../../../../core/common/widgets/icon_bubble.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/common/widgets/step_progress_indicator.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/auth_controller.dart';

class EnterOtpScreen extends GetView<AuthController> {
  const EnterOtpScreen({super.key});

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
                const StepProgressIndicator(stepCount: 3, activeIndex: 1),
                SizedBox(height: 64.h),
                Center(
                  child: IconBubble(
                    imagePath: 'assets/icon/mail.png',
                    backgroundColor: AppColors.iconBubbleBlue,
                  ),
                ),
                SizedBox(height: 29.h),
                Text(
                  'Enter OTP',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 29.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authTextDark,
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  'Enter the OTP code we just sent you on your registered Email/Phone number',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 12.8,
                    color: AppColors.mutedText,
                  ),
                ),
                SizedBox(height: 33.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45.w,
                      height: 64.h,
                      child: TextField(
                        controller: controller.otpControllers[index],
                        focusNode: controller.otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authTextDark,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.fieldBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            controller.onOtpChanged(index, value),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => Column(
                    children: [
                      LinearProgressIndicator(
                        value: controller.otpSecondsLeft.value / 120,
                        minHeight: 5.h,
                        borderRadius: BorderRadius.circular(99.r),
                        color: AppColors.onboardingBackground,
                        backgroundColor: AppColors.fieldBackground,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'OTP expires in ${controller.otpTimerLabel}',
                        textAlign: TextAlign.center,
                        style: getTextStyle(
                          fontSize: 11.9,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => PrimaryButton(
                    label: controller.currentOtpFlow.value == OtpFlow.signup
                        ? 'Verify Account'
                        : 'Reset Password',
                    isLoading: controller.isOtpSubmitting.value,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    textColor: Colors.white,
                    height: 55,
                    borderRadius: 14,
                    fontSize: 14.6,
                    onPressed: controller.submitOtp,
                  ),
                ),
                SizedBox(height: 15.h),
                Obx(
                  () => GestureDetector(
                    onTap: controller.canResendOtp
                        ? controller.resendOtp
                        : null,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Didn't get OTP? ",
                            style: getTextStyle(
                              fontSize: 11.9,
                              color: AppColors.helperText,
                            ),
                          ),
                          TextSpan(
                            text: controller.isResendingOtp.value
                                ? 'Sending...'
                                : 'Resend OTP',
                            style: getTextStyle(
                              fontSize: 11.9,
                              color: controller.canResendOtp
                                  ? AppColors.authLink
                                  : AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
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
