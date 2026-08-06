import 'package:flutter/material.dart';

class FeatureToggleItem {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  const FeatureToggleItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
