import 'package:flutter/material.dart';

import '../../../core/utils/constants/colors.dart';

enum OrderStatus {
  complete,
  ongoing;

  String get label => switch (this) {
    OrderStatus.complete => 'Complete',
    OrderStatus.ongoing => 'Ongoing',
  };

  Color get textColor => switch (this) {
    OrderStatus.complete => AppColors.stockBadgeText,
    OrderStatus.ongoing => AppColors.ongoingBadgeText,
  };

  List<Color> get gradient => switch (this) {
    OrderStatus.complete => [
      AppColors.completeBadgeStart,
      AppColors.completeBadgeEnd,
    ],
    OrderStatus.ongoing => [
      AppColors.ongoingBadgeStart,
      AppColors.ongoingBadgeEnd,
    ],
  };
}

class TableOrder {
  final String tableName;
  final String orderId;
  final String customerName;
  final String time;
  final OrderStatus status;

  const TableOrder({
    required this.tableName,
    required this.orderId,
    required this.customerName,
    required this.time,
    required this.status,
  });
}
