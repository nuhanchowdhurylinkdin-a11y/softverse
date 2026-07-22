import 'package:flutter/material.dart';

import '../styles/global_text_style.dart';
import '../../utils/constants/colors.dart';

class ComingSoonView extends StatelessWidget {
  final String label;

  const ComingSoonView({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '$label — coming soon',
          style: getTextStyle(fontSize: 16, color: AppColors.chipInactiveText),
        ),
      ),
    );
  }
}
