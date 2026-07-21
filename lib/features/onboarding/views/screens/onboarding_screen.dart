import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.onboardingBackground,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 64.h),
                Image.asset(
                  'assets/logo/Logo-white.png',
                  width: 260.w,
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'REGISTRATION',
                  backgroundColor: Colors.white,
                  textColor: AppColors.onboardingBackground,
                  height: 51,
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.08,
                  onPressed: controller.goToRegistration,
                ),
                SizedBox(height: 18.h),
                PrimaryButton(
                  label: 'SIGN IN',
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.lightBorder,
                  borderColor: AppColors.lightBorder,
                  height: 51,
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.08,
                  onPressed: controller.goToSignIn,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
