import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/walkthrough_controller.dart';
import '../../widgets/feature_toggle_tile.dart';

class FeatureSettingsScreen extends GetView<WalkthroughController> {
  const FeatureSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 14.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: controller.skipFeatureSettings,
                    child: Icon(
                      Icons.close,
                      size: 22.sp,
                      color: AppColors.authTextDark,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: controller.saveFeatureSettings,
                    child: Text(
                      'SAVE',
                      style: getTextStyle(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 59.h),
              Text(
                'Feature settings',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 18.2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authTextDark,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Choose the features you want to use. You can change '
                'these settings later in the Back office.',
                textAlign: TextAlign.center,
                style: getTextStyle(fontSize: 12.8, color: AppColors.mutedText),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.features.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: AppColors.fieldDivider,
                  ),
                  itemBuilder: (context, index) {
                    return Obx(
                      () => FeatureToggleTile(
                        item: controller.features[index],
                        value: controller.featureToggles[index].value,
                        onChanged: (_) => controller.toggleFeature(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
