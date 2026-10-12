import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

/// 0-9 keypad with a backspace key, for entering the PIN.
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final key in row) _key(key)],
            ),
          ),
      ],
    );
  }

  Widget _key(String key) {
    if (key.isEmpty) return SizedBox(width: 72.w, height: 72.w);
    final isBack = key == '<';
    return SizedBox(
      width: 72.w,
      height: 72.w,
      child: Material(
        color: isBack ? Colors.transparent : AppColors.fieldBackground,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isBack ? onBackspace : () => onDigit(key),
          child: Center(
            child: isBack
                ? Icon(
                    Icons.backspace_outlined,
                    size: 24.sp,
                    color: AppColors.chipInactiveText,
                  )
                : Text(
                    key,
                    style: getTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// The filled/empty dots showing how many PIN digits were typed.
class PinDots extends StatelessWidget {
  final int filled;
  final int length;

  const PinDots({super.key, required this.filled, required this.length});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled
                  ? AppColors.onboardingBackground
                  : Colors.transparent,
              border: Border.all(
                color: AppColors.onboardingBackground,
                width: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}
