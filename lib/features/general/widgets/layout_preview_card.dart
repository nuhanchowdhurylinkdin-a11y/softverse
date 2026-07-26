import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/widgets/radio_circle.dart';
import '../../../core/utils/constants/colors.dart';
import '../controller/general_controller.dart';

class LayoutPreviewCard extends StatelessWidget {
  final HomeScreenLayout layout;
  final bool selected;
  final VoidCallback onTap;

  const LayoutPreviewCard({
    super.key,
    required this.layout,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGrid = layout == HomeScreenLayout.grid;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 168.w,
            height: 358.h,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border.all(
                color: selected ? AppColors.authLink : AppColors.cardBorder,
                width: selected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PreviewBlock(height: 10.h, radius: 6.r),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(child: _PreviewBlock(height: 20.h)),
                    SizedBox(width: 6.w),
                    Expanded(child: _PreviewBlock(height: 20.h)),
                  ],
                ),
                SizedBox(height: 8.h),
                _PreviewBlock(height: 34.h, radius: 8.r),
                SizedBox(height: 8.h),
                Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 6.w : 0),
                        child: _PreviewBlock(height: 16.h, radius: 8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: isGrid ? const _GridContent() : const _ListContent(),
                ),
                SizedBox(height: 8.h),
                _BottomNavPreview(),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioCircle(selected: selected),
                SizedBox(width: 8.w),
                Text(
                  isGrid ? 'Grid' : 'List',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.chipInactiveText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewBlock extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const _PreviewBlock({required this.height, this.width, this.radius = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.lightBorder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _GridContent extends StatelessWidget {
  const _GridContent();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 6.h,
      crossAxisSpacing: 6.w,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (i) => const _GridTile()),
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          _PreviewBlock(height: 6.h),
          SizedBox(height: 3.h),
          _PreviewBlock(height: 6.h, width: 24.w),
        ],
      ),
    );
  }
}

class _ListContent extends StatelessWidget {
  const _ListContent();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, _) => SizedBox(height: 6.h),
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PreviewBlock(height: 6.h),
                  SizedBox(height: 3.h),
                  _PreviewBlock(height: 6.h, width: 30.w),
                ],
              ),
            ),
            Icon(
              Iconsax.shopping_cart,
              size: 12.sp,
              color: AppColors.chipInactiveText,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const icons = [
      Iconsax.home,
      Iconsax.shopping_cart,
      Iconsax.repeat,
      Iconsax.box,
      Iconsax.menu,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        icons.length,
        (i) => Icon(
          icons[i],
          size: 12.sp,
          color: i == icons.length - 1
              ? AppColors.authLink
              : AppColors.chipInactiveText,
        ),
      ),
    );
  }
}
