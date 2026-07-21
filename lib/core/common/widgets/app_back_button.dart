import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants/colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;

  const AppBackButton({
    super.key,
    this.onTap,
    this.color = AppColors.authTextDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: onTap ?? Get.back,
        icon: Icon(Icons.arrow_back_ios_new, color: color, size: 20),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
