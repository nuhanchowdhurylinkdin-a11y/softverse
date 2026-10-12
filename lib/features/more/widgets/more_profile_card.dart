import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class MoreProfileCard extends StatelessWidget {
  final String name;
  final String role;
  /// The POS device chosen at login - shown, not switchable from here.
  final String posLabel;

  const MoreProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.posLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.billCardStart,
            AppColors.onboardingBackground,
            AppColors.billCardStart,
          ],
          stops: [0, 0.5, 1],
        ),
      ),
      child: Row(
        children: [
          // Initials instead of a stock photo of a stranger.
          Container(
            width: 60.w,
            height: 60.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(name),
              style: getTextStyle(
                fontSize: 21.9,
                fontWeight: FontWeight.w700,
                color: AppColors.onboardingBackground,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  role,
                  style: getTextStyle(fontSize: 12.8, color: Colors.white),
                ),
              ],
            ),
          ),
          if (posLabel.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                posLabel,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }
}
