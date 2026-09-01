import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String? tooltip;

  const FloatingIconButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 51.w,
        height: 51.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22.sp, color: iconColor),
      ),
    );
    if (tooltip == null) return button;
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(message: tooltip!, child: button),
    );
  }
}
