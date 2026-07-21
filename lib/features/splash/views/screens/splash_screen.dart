import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/theme/app_colors_extension.dart';
import '../../controller/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.cardBg,
      body: Center(
        child: Image.asset(
          'assets/logo/logo.png',
          width: 360.w,
        ),
      ),
    );
  }
}
