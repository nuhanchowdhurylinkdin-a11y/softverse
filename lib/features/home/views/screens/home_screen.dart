import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/controller/theme_controller.dart';
import '../../../../core/utils/theme/app_colors_extension.dart';
import '../../controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: c.cardBg,
        elevation: 0,
        title: Text(
          'Softverse',
          style: getTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
                onPressed: themeCtrl.toggle,
                icon: Icon(themeCtrl.icon, color: c.textPrimary),
              )),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Counter',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(() => Text(
                  '${controller.counter.value}',
                  style: getTextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                )),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  onTap: controller.decrement,
                  color: const Color(0xFFEF4444),
                ),
                SizedBox(width: 16.w),
                _CounterButton(
                  icon: Icons.refresh,
                  onTap: controller.reset,
                  color: c.textSecondary,
                ),
                SizedBox(width: 16.w),
                _CounterButton(
                  icon: Icons.add,
                  onTap: controller.increment,
                  color: const Color(0xFF0F58BD),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CounterButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 28.sp),
      ),
    );
  }
}
