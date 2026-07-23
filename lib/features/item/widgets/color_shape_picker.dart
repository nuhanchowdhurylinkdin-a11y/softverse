import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/constants/colors.dart';

class ColorShapePicker extends StatelessWidget {
  static const colors = [
    AppColors.itemColorGray,
    AppColors.dangerRed,
    AppColors.itemColorPink,
    AppColors.ongoingBadgeText,
    AppColors.itemColorMint,
    AppColors.itemColorTeal,
    AppColors.authLink,
    AppColors.itemColorPurple,
  ];

  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;
  final int selectedShapeIndex;
  final ValueChanged<int> onShapeSelected;

  const ColorShapePicker({
    super.key,
    required this.selectedColorIndex,
    required this.onColorSelected,
    required this.selectedShapeIndex,
    required this.onShapeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _swatchRow(List.generate(4, (i) => i)),
        SizedBox(height: 24.h),
        _swatchRow(List.generate(4, (i) => i + 4)),
        SizedBox(height: 24.h),
        _shapeRow(),
      ],
    );
  }

  Widget _swatchRow(List<int> indices) {
    return Row(
      children: [
        for (final i in indices) ...[
          if (i != indices.first) SizedBox(width: 24.w),
          Expanded(
            child: GestureDetector(
              onTap: () => onColorSelected(i),
              child: Container(
                height: 80.h,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(8.r),
                  border: selectedColorIndex == i
                      ? Border.all(
                          color: AppColors.onboardingBackground,
                          width: 2,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _shapeRow() {
    final shapes = <Widget Function(bool selected)>[
      (selected) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected
                ? AppColors.onboardingBackground
                : AppColors.lightBorder,
            width: selected ? 2 : 1,
          ),
        ),
      ),
      (selected) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.onboardingBackground
                : AppColors.lightBorder,
            width: selected ? 2 : 1,
          ),
        ),
      ),
      (selected) => Icon(
        Icons.star_outline,
        size: 80.w,
        color: selected
            ? AppColors.onboardingBackground
            : AppColors.lightBorder,
      ),
      (selected) => Icon(
        Icons.hexagon_outlined,
        size: 80.w,
        color: selected
            ? AppColors.onboardingBackground
            : AppColors.lightBorder,
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < shapes.length; i++) ...[
          if (i != 0) SizedBox(width: 24.w),
          Expanded(
            child: GestureDetector(
              onTap: () => onShapeSelected(i),
              child: SizedBox(
                height: 80.h,
                child: shapes[i](selectedShapeIndex == i),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
