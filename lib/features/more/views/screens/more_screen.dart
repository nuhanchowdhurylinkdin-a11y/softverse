import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../home/widgets/pos_app_bar.dart';
import '../../controller/more_controller.dart';
import '../../widgets/more_menu_tile.dart';
import '../../widgets/more_profile_card.dart';

class MoreScreen extends GetView<MoreController> {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            PosAppBar(title: 'POS-1', leadingIcon: Iconsax.mobile),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MoreProfileCard(
                      imageUrl: controller.profileImageUrl,
                      name: controller.profileName,
                      role: controller.profileRole,
                      posLabel: controller.posLabel,
                      onSwitchPos: controller.switchPos,
                    ),
                    SizedBox(height: 16.h),
                    MoreMenuTile(
                      icon: Iconsax.clock,
                      label: 'Shift',
                      onTap: controller.openShift,
                    ),
                    SizedBox(height: 12.h),
                    MoreMenuTile(
                      icon: Iconsax.task_square,
                      label: 'Item',
                      onTap: controller.openItem,
                    ),
                    SizedBox(height: 12.h),
                    MoreMenuTile(
                      icon: Iconsax.user,
                      label: 'Customer',
                      onTap: controller.openCustomer,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Icon(
                          Iconsax.setting_2,
                          size: 22.sp,
                          color: AppColors.chipInactiveText,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Settings',
                          style: getTextStyle(
                            fontSize: 14.6,
                            fontWeight: FontWeight.w500,
                            color: AppColors.chipInactiveText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: MoreMenuTile(
                            icon: Iconsax.printer,
                            label: 'Printer',
                            centered: true,
                            onTap: controller.openPrinterSettings,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: MoreMenuTile(
                            icon: Iconsax.mobile,
                            label: 'Apps',
                            centered: true,
                            onTap: controller.openAppsSettings,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: MoreMenuTile(
                            icon: Iconsax.cpu_setting,
                            label: 'General',
                            centered: true,
                            onTap: controller.openGeneralSettings,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: MoreMenuTile(
                            icon: Iconsax.percentage_circle,
                            label: 'Taxes',
                            centered: true,
                            onTap: controller.openTaxesSettings,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 56.h),
                    MoreMenuTile(
                      icon: Iconsax.element_2,
                      label: 'Back Office',
                      onTap: controller.openBackOffice,
                    ),
                    SizedBox(height: 12.h),
                    MoreMenuTile(
                      icon: Iconsax.mobile,
                      label: 'Apps Integration',
                      onTap: controller.openAppsIntegration,
                    ),
                    SizedBox(height: 12.h),
                    MoreMenuTile(
                      icon: Iconsax.headphone,
                      label: 'Supports',
                      onTap: controller.openSupport,
                    ),
                    SizedBox(height: 52.h),
                    Center(
                      child: PrimaryButton(
                        label: 'Log out',
                        onPressed: controller.logout,
                        backgroundColor: AppColors.dangerRed,
                        textColor: Colors.white,
                        width: 197.w,
                        height: 68,
                        fontSize: 16.4,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
