import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/walkthrough_controller.dart';
import '../../widgets/walkthrough_slide.dart';

class WalkthroughScreen extends GetView<WalkthroughController> {
  const WalkthroughScreen({super.key});

  static const _slides = [
    (
      image: 'assets/images/walkthrough/mobile_pos.jpg',
      title: 'Mobile Point of Sale',
      description:
          'Sell using your smartphone or tablet, provide printed or '
          'digital receipts, accept various payment options, and much more.',
    ),
    (
      image: 'assets/images/walkthrough/back_office.jpg',
      title: 'Back Office',
      description:
          'Monitor your sales and stock levels, and efficiently handle '
          'your team and clients from any device using a web browser.',
    ),
    (
      image: 'assets/images/walkthrough/complementary_apps.jpg',
      title: 'Complementary Apps',
      description:
          'Set up the Softverse Dashboard, Kitchen Display, and Customer '
          'Display applications to enhance your business management efficiency.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: _slides
                    .map((s) => WalkthroughSlide(
                          imagePath: s.image,
                          title: s.title,
                          description: s.description,
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 51.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(
                  () => Row(
                    children: [
                      SizedBox(
                        width: 65.w,
                        child: controller.currentPage.value > 0
                            ? GestureDetector(
                                onTap: controller.previousPage,
                                child: Text(
                                  'BACK',
                                  style: getTextStyle(
                                    fontSize: 12.8,
                                    color: AppColors.onboardingBackground,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            WalkthroughController.slideCount,
                            (index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.w),
                              width: 7.w,
                              height: 7.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.currentPage.value == index
                                    ? AppColors.onboardingBackground
                                    : AppColors.fieldBackground,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 65.w,
                        child: GestureDetector(
                          onTap: controller.nextPage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                controller.currentPage.value ==
                                        WalkthroughController.slideCount - 1
                                    ? 'DONE'
                                    : 'NEXT',
                                style: getTextStyle(
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onboardingBackground,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14.sp,
                                color: AppColors.onboardingBackground,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
