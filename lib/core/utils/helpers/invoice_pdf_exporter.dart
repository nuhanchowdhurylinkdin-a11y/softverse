import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../features/checkout/models/cart_item.dart';
import '../../services/business_profile_service.dart';
import 'app_helper.dart';
import 'receipt_labels.dart';

class InvoicePdfExporter {
  InvoicePdfExporter._();

  static Future<File> exportInvoice({
    required String invoiceNumber,
    required String customerName,
    required DateTime dateTime,
    required List<CartItem> items,
    required double subtotal,
    double discount = 0,
    required double tax,
    required double totalAmount,
    required double amountReceived,
    required double changeToReturn,
    double amountDue = 0,
    required String paymentLabel,
    String businessName = 'Softverse POS',
    String businessAddress = '',
    String businessPhone = '',
    String? branchName,
    String? servedBy,
    String? posName,
  }) async {
    final fileName = '${invoiceNumber.replaceAll(' ', '_')}.pdf';
    // The documents directory persists across app restarts and OS cache
    // clears, unlike systemTemp — a downloaded invoice shouldn't vanish.
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(
      _buildPdf(
        invoiceNumber: invoiceNumber,
        customerName: customerName,
        dateTime: dateTime,
        items: items,
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        totalAmount: totalAmount,
        amountReceived: amountReceived,
        changeToReturn: changeToReturn,
        amountDue: amountDue,
        paymentLabel: paymentLabel,
        businessName: businessName,
        businessAddress: businessAddress,
        businessPhone: businessPhone,
        saleInfo: [
          if (branchName?.trim().isNotEmpty == true)
            'Branch: ${branchName!.trim()}',
          if (servedBy?.trim().isNotEmpty == true)
            'Served by: ${servedBy!.trim()}',
          if (posName?.trim().isNotEmpty == true) 'POS: ${posName!.trim()}',
        ],
      ),
      flush: true,
    );
    return file;
  }

  static const _downloads = MethodChannel('softverse/downloads');

  /// Saves the PDF like a browser download: on Android it goes straight
  /// into Downloads with a "download complete" notification that opens it.
  /// iOS (no Downloads folder) and Android 9 and older fall back to the
  /// native "Save as" dialog. Returns true if the file was saved.
  static Future<bool> saveToDevice(File file) async {
    final bytes = await file.readAsBytes();
    final fileName = file.uri.pathSegments.last;
    if (Platform.isAndroid) {
      try {
        final saved = await _downloads.invokeMethod<bool>('saveToDownloads', {
          'bytes': bytes,
          'fileName': fileName,
          'mimeType': 'application/pdf',
        });
        if (saved == true) {
          AppHelperFunctions.showSuccessSnackBar('Saved to Downloads');
          return true;
        }
      } on PlatformException {
        // Fall through to the picker.
      }
    }
    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save invoice PDF',
      fileName: fileName,
      bytes: bytes,
    );
    if (savedPath == null) return false;
    AppHelperFunctions.showSuccessSnackBar('Invoice saved.');
    return true;
  }

  /// Hands the exported PDF to the OS share sheet so the user can send it to
  /// another app (Drive, Messages, etc.) instead of saving it locally.
  static Future<void> share(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        fileNameOverrides: [file.uri.pathSegments.last],
      ),
    );
  }

  static Uint8List _buildPdf({
    required String invoiceNumber,
    required String customerName,
    required DateTime dateTime,
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double totalAmount,
    required double amountReceived,
    required double changeToReturn,
    required double amountDue,
    required String paymentLabel,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
    List<String> saleInfo = const [],
  }) {
    final isDue = paymentLabel == 'Due Payment';
    // Same wording as the printed receipt, in the website's receipt language.
    String l(String key, [String? english]) {
      final translated = ReceiptLabels.t(key);
      return translated == key ? english ?? key : translated;
    }

    final lines = [
      businessName,
      if (businessAddress.isNotEmpty) businessAddress,
      if (businessPhone.isNotEmpty) '${l('Tel')}: $businessPhone',
      '${l('Invoice')}: $invoiceNumber',
      AppHelperFunctions.getFormattedDate(
        dateTime,
        format: 'dd MMM yyyy, hh:mm a',
      ),
      '${l('Customer')}: $customerName',
      '${l('Payment')}: $paymentLabel',
      ...saleInfo,
      '',
      l('Items'),
      for (final item in items) ...[
        '${item.name}  x${item.quantity}    ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(item.price * item.quantity)}',
        '  @ ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(item.price)}',
      ],
      '',
      '${l('Subtotal')}: ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(subtotal)}',
      if (discount > 0)
        '${l('Discount')}: -${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(discount)}',
      '${l('Tax')}: ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(tax)}',
      '${l('Total')}: ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(totalAmount)}',
      // A due/credit sale hasn't actually received anything yet - showing
      // "Amount Received"/"Change" on it would make it look already paid.
      if (isDue) ...[
        if (amountReceived > 0)
          '${l('Paid so far')}: ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(amountReceived)}',
        '${l('Amount due', 'Amount Due')}: ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(amountDue)}',
      ] else ...[
        '${l('Received', 'Amount Received')}: ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(amountReceived)}',
        '${l('Change', 'Change to Return')}: ${BusinessProfileService.printCurrencySymbol}${AppHelperFunctions.getFormattedMoney(changeToReturn)}',
      ],
    ];

    final content = StringBuffer()
      ..writeln('BT')
      ..writeln('/F1 18 Tf')
      ..writeln('50 780 Td')
      ..writeln('(${_escape(lines.first)}) Tj')
      ..writeln('/F1 11 Tf');

    for (final line in lines.skip(1)) {
      content
        ..writeln('0 -18 Td')
        ..writeln('(${_escape(line)}) Tj');
    }
    content.writeln('ET');

    final stream = content.toString();
    final objects = <String>[
      '1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n',
      '2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n',
      '3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>\nendobj\n',
      '4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n',
      '5 0 obj\n<< /Length ${latin1.encode(stream).length} >>\nstream\n$stream\nendstream\nendobj\n',
    ];

    final buffer = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[0];
    var length = latin1.encode(buffer.toString()).length;
    for (final object in objects) {
      offsets.add(length);
      buffer.write(object);
      length += latin1.encode(object).length;
    }

    final xrefOffset = length;
    buffer
      ..writeln('xref')
      ..writeln('0 ${objects.length + 1}')
      ..writeln('0000000000 65535 f ');
    for (final offset in offsets.skip(1)) {
      buffer.writeln('${offset.toString().padLeft(10, '0')} 00000 n ');
    }
    buffer
      ..writeln('trailer')
      ..writeln('<< /Size ${objects.length + 1} /Root 1 0 R >>')
      ..writeln('startxref')
      ..writeln(xrefOffset)
      ..writeln('%%EOF');

    return Uint8List.fromList(latin1.encode(buffer.toString()));
  }

  static String _escape(String value) {
    return value
        .replaceAll('\\', r'\\')
        .replaceAll('(', r'\(')
        .replaceAll(')', r'\)');
  }
}
