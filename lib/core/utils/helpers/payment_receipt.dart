import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../features/printer/controller/printer_controller.dart';
import '../constants/api_constants.dart';
import 'invoice_pdf_exporter.dart';

/// Hands the customer proof of a collected due payment: on the receipt
/// printer when one is set up, otherwise the payment receipt PDF the server
/// generated, through the save/share sheet. Used wherever a due payment is
/// collected (an invoice, or the Due Balances list).
Future<void> handOverPaymentReceipt({
  required String orderNumber,
  required String customerName,
  required double previousDue,
  required double amountPaid,
  required double remainingDue,
  String? paymentReceiptUrl,
}) async {
  final printed =
      Get.isRegistered<PrinterController>() &&
      await Get.find<PrinterController>().printPaymentReceipt(
        orderNumber: orderNumber,
        customerName: customerName,
        dateTime: DateTime.now(),
        previousDue: previousDue,
        amountPaid: amountPaid,
        remainingDue: remainingDue,
      );
  if (printed) return;

  final url = paymentReceiptUrl?.trim();
  if (url == null || url.isEmpty) return;
  final file = await _download(url, orderNumber);
  if (file != null) await InvoicePdfExporter.saveToDevice(file);
}

/// The payment receipt lives at a plain static URL (like a logo/upload, not
/// the auth-gated `/checkout/:id/receipt`), so it needs no bearer token.
Future<File?> _download(String url, String orderNumber) async {
  try {
    final resolved = Uri.parse(url).isAbsolute
        ? url
        : ApiConstants.resolveAssetUrl(url);
    final response = await http.get(Uri.parse(resolved));
    if (response.statusCode != 200) return null;

    final filename =
        'Payment_${orderNumber.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.pdf';
    final file = File('${Directory.systemTemp.path}/$filename');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file;
  } catch (_) {
    return null;
  }
}
