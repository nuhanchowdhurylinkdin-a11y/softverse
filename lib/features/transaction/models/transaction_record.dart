import 'package:flutter/material.dart';

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
  final String companyName;
  final String invoiceNumber;
  final String orderId;
  final String dateTime;
  final PaymentType paymentType;

  const TransactionRecord({
    required this.companyName,
    required this.invoiceNumber,
    required this.orderId,
    required this.dateTime,
    required this.paymentType,
  });
}
