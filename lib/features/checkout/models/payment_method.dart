import 'package:flutter/material.dart';

class PaymentMethod {
  final String key;
  final String label;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const PaymentMethod({
    required this.key,
    required this.label,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });
}
