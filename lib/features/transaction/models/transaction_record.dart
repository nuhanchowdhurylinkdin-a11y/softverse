import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/constants/colors.dart';

enum PaymentType {
  cash,
  card,
  due,
  installment,
  refund;

  String get label => switch (this) {
    PaymentType.cash => 'Cash Payment',
    PaymentType.card => 'Card Payment',
    PaymentType.due => 'Due Payment',
    PaymentType.installment => 'Installment',
    PaymentType.refund => 'Refund',
  };

  Color get textColor => switch (this) {
    PaymentType.cash => AppColors.stockBadgeText,
    PaymentType.card => AppColors.checkoutGoldEnd,
    PaymentType.due => AppColors.dueEnd,
    PaymentType.installment => AppColors.installmentBadgeText,
    PaymentType.refund => AppColors.dangerRed,
  };

  List<Color> get gradient => switch (this) {
    PaymentType.cash => [
      AppColors.completeBadgeStart,
      AppColors.completeBadgeEnd,
    ],
    PaymentType.card => [
      AppColors.ongoingBadgeStart,
      AppColors.ongoingBadgeEnd,
    ],
    PaymentType.due => [AppColors.dueStart, AppColors.dueEnd],
    PaymentType.installment => [
      AppColors.installmentStart,
      AppColors.installmentEnd,
    ],
    PaymentType.refund => [AppColors.dangerRed, AppColors.dangerRed],
  };
}

class TransactionRecord {
  final String id;
  final Map<String, dynamic> raw;
  final String companyName;
  final String invoiceNumber;
  final String orderId;
  final String dateTime;
  final PaymentType paymentType;
  final String status;
  final double totalAmount;

  const TransactionRecord({
    required this.id,
    required this.raw,
    required this.companyName,
    required this.invoiceNumber,
    required this.orderId,
    required this.dateTime,
    required this.paymentType,
    required this.status,
    required this.totalAmount,
  });

  factory TransactionRecord.fromApi(Map<String, dynamic> json) {
    final payment = json['paymentMethod']?.toString();
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    return TransactionRecord(
      id: json['id']?.toString() ?? '',
      raw: json,
      companyName: _clean(json['customerName']) ?? 'Not registered',
      invoiceNumber:
          _clean(json['invoiceNumber']) ??
          _clean(json['transactionNumber']) ??
          _clean(json['orderNumber']) ??
          'Invoice',
      orderId: _clean(json['orderNumber']) ?? _clean(json['id']) ?? '',
      dateTime: createdAt == null
          ? ''
          : DateFormat('dd/MM/yyyy hh:mma').format(createdAt).toLowerCase(),
      paymentType: _paymentTypeFrom(payment),
      status: json['status']?.toString() ?? '',
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '') ?? 0,
    );
  }

  static String? _clean(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }

  static PaymentType _paymentTypeFrom(String? value) {
    return switch (value) {
      'card' => PaymentType.card,
      'due' => PaymentType.due,
      'installment' => PaymentType.installment,
      'refund' => PaymentType.refund,
      _ => PaymentType.cash,
    };
  }
}
