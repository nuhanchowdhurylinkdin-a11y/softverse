import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class DashedDivider extends StatelessWidget {
  final Color color;
  final double dashWidth;
  final double dashGap;
  final double height;

  const DashedDivider({
    super.key,
    this.color = AppColors.dashedDividerColor,
    this.dashWidth = 6,
    this.dashGap = 4,
    this.height = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();
          return Row(
            children: List.generate(
              count,
              (_) => Padding(
                padding: EdgeInsets.only(right: dashGap),
                child: Container(
                  width: dashWidth,
                  height: height,
                  color: color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
