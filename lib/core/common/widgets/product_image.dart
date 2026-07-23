import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../utils/constants/colors.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 55,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: Image.network(
        imageUrl,
        width: size.w,
        height: size.w,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(
            child: SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _placeholder(
            child: Icon(
              Iconsax.image,
              size: size.w * 0.5,
              color: AppColors.chipInactiveText,
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder({required Widget child}) {
    return Container(
      width: size.w,
      height: size.w,
      alignment: Alignment.center,
      color: AppColors.chipBackground,
      child: child,
    );
  }
}
