import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_back_button.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/auth_controller.dart';

class RegistrationScreen extends GetView<AuthController> {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),
                const AppBackButton(),
                SizedBox(height: 20.h),
                Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 32.8,
                    fontWeight: FontWeight.w500,
                    color: AppColors.authTextDark,
                  ).copyWith(letterSpacing: 0.66),
                ),
                SizedBox(height: 22.h),
                AppTextField(
                  label: 'Full Name',
                  hintText: 'john Dheere',
                  controller: controller.fullNameController,
                  backgroundColor: AppColors.fieldBackground,
                  borderStyle: AppTextFieldBorder.none,
                  borderRadius: 14,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 16.h,
                  ),
                ),
                SizedBox(height: 11.h),
                AppTextField(
                  label: 'Business Name',
                  hintText: 'john Dheere',
                  controller: controller.businessNameController,
                  backgroundColor: AppColors.fieldBackground,
                  borderStyle: AppTextFieldBorder.none,
                  borderRadius: 14,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 16.h,
                  ),
                ),
                SizedBox(height: 11.h),
                AppTextField(
                  label: 'Email',
                  hintText: 'johndheere@gmail.com',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  backgroundColor: AppColors.fieldBackground,
                  borderStyle: AppTextFieldBorder.none,
                  borderRadius: 14,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 16.h,
                  ),
                ),
                SizedBox(height: 11.h),
                AppTextField(
                  label: 'Create Password',
                  controller: controller.createPasswordController,
                  obscureText: true,
                  backgroundColor: AppColors.fieldBackground,
                  borderStyle: AppTextFieldBorder.none,
                  borderRadius: 14,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 16.h,
                  ),
                ),
                SizedBox(height: 11.h),
                AppTextField(
                  label: 'Confirm Password',
                  controller: controller.confirmPasswordController,
                  obscureText: true,
                  backgroundColor: AppColors.fieldBackground,
                  borderStyle: AppTextFieldBorder.none,
                  borderRadius: 14,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 16.h,
                  ),
                ),
                SizedBox(height: 36.h),
                PrimaryButton(
                  label: 'Sign up',
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  textColor: Colors.white,
                  height: 51,
                  fontSize: 16.4,
                  letterSpacing: 0.08,
                  onPressed: controller.register,
                ),
                SizedBox(height: 21.h),
                GestureDetector(
                  onTap: controller.goToSignIn,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'If have an account ? ',
                          style: getTextStyle(
                            fontSize: 10.9,
                            color: AppColors.authTextDark,
                          ),
                        ),
                        TextSpan(
                          text: 'Sign in Now',
                          style: getTextStyle(
                            fontSize: 10.9,
                            color: AppColors.authLink,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
