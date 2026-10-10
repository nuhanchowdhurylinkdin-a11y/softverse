import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/store/controller/store_controller.dart';
import '../styles/global_text_style.dart';

/// The paired POS device name with its store underneath - replaces the old
/// hardcoded "POS-1" shown in the app bars and the drawer header.
class TillIdentityTitle extends StatelessWidget {
  final Color color;
  final Color subtitleColor;
  final double fontSize;

  const TillIdentityTitle({
    super.key,
    this.color = Colors.white,
    this.subtitleColor = Colors.white70,
    this.fontSize = 21.9,
  });

  @override
  Widget build(BuildContext context) {
    final store = Get.find<StoreController>();
    return Obx(() {
      final pos = store.currentPosName.value;
      final storeName = store.currentStoreName.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (pos == null || pos.isEmpty) ? 'POS' : pos,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
              textAlign: TextAlign.left,
            ),
          ),
          if (storeName != null && storeName.isNotEmpty)
            Text(
              storeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(
                fontSize: fontSize * 0.55,
                color: subtitleColor,
                textAlign: TextAlign.left,
              ),
            ),
        ],
      );
    });
  }
}
