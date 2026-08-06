import 'package:flutter/material.dart';

import '../../../core/utils/constants/colors.dart';

enum OrderStatus {
  complete,
  ongoing,
  available,
  paid;

  String get label => switch (this) {
    OrderStatus.complete => 'Complete',
    OrderStatus.ongoing => 'Ongoing',
    OrderStatus.available => 'Available',
    OrderStatus.paid => 'Paid',
  };

  Color get textColor => switch (this) {
    OrderStatus.complete => AppColors.stockBadgeText,
    OrderStatus.ongoing => AppColors.ongoingBadgeText,
    OrderStatus.available => AppColors.stockBadgeText,
    OrderStatus.paid => AppColors.stockBadgeText,
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
    OrderStatus.available => [
      AppColors.completeBadgeStart,
      AppColors.completeBadgeEnd,
    ],
    OrderStatus.paid => [
      AppColors.completeBadgeStart,
      AppColors.completeBadgeEnd,
    ],
  };
}

class TableOrder {
  final String tableId;
  final String? id;
  final String tableName;
  final String orderId;
  final String customerName;
  final String time;
  final OrderStatus status;
  final String availability;
  final int? capacity;
  final Map<String, dynamic>? currentOrder;

  const TableOrder({
    required this.tableId,
    this.id,
    required this.tableName,
    required this.orderId,
    required this.customerName,
    required this.time,
    required this.status,
    required this.availability,
    this.capacity,
    this.currentOrder,
  });

  bool get isAvailable => availability == 'available';

  bool get hasOrder => id != null && id!.isNotEmpty;

  factory TableOrder.fromApi(Map<String, dynamic> table) {
    final currentOrder = table['currentOrder'] is Map
        ? Map<String, dynamic>.from(table['currentOrder'] as Map)
        : null;
    final availability = table['availability']?.toString() ?? 'booked';
    final statusLabel = currentOrder?['statusLabel']?.toString().toLowerCase();
    return TableOrder(
      tableId: table['tableId']?.toString() ?? table['id']?.toString() ?? '',
      id: currentOrder?['id']?.toString(),
      tableName: table['tableName']?.toString() ?? 'Table',
      orderId: currentOrder?['orderNumber']?.toString() ?? '',
      customerName:
          currentOrder?['customerName']?.toString() ?? 'Not registered',
      time: currentOrder?['openedAtLabel']?.toString() ?? '',
      status: availability == 'available'
          ? OrderStatus.available
          : availability == 'paid'
          ? OrderStatus.paid
          : statusLabel == 'complete'
          ? OrderStatus.complete
          : OrderStatus.ongoing,
      availability: availability,
      capacity: int.tryParse(table['capacity']?.toString() ?? ''),
      currentOrder: currentOrder,
    );
  }
}
