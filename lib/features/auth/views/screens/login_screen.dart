import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_back_button.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

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
                SizedBox(height: 46.h),
                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 32.8,
                    fontWeight: FontWeight.w500,
                    color: AppColors.authTextDark,
                  ).copyWith(letterSpacing: 0.66),
                ),
                SizedBox(height: 102.h),
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
                  label: 'Password',
                  controller: controller.passwordController,
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
                GestureDetector(
                  onTap: controller.goToForgotPassword,
                  child: Text(
                    'Forgot password',
                    style: getTextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authLink,
                    ),
                  ),
                ),
                SizedBox(height: 36.h),
                Obx(
                  () => PrimaryButton(
                    label: 'Sign in',
                    isLoading: controller.isLoginSubmitting.value,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    textColor: Colors.white,
                    height: 51,
                    fontSize: 16.4,
                    letterSpacing: 0.08,
                    onPressed: controller.login,
                  ),
                ),
                SizedBox(height: 21.h),
                GestureDetector(
                  onTap: controller.goToRegistration,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have account ? ",
                          style: getTextStyle(
                            fontSize: 10.9,
                            color: AppColors.authTextDark,
                          ),
                        ),
                        TextSpan(
                          text: 'Register Now',
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
