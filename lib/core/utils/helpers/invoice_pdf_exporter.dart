import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../features/checkout/models/cart_item.dart';
import 'app_helper.dart';

class InvoicePdfExporter {
  InvoicePdfExporter._();

  static Future<File> exportInvoice({
    required String invoiceNumber,
    required String customerName,
    required String orderId,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double totalAmount,
    required double amountReceived,
    required double changeToReturn,
    String businessName = 'Softverse POS',
    String businessAddress = '',
    String businessPhone = '',
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
        orderId: orderId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        totalAmount: totalAmount,
        amountReceived: amountReceived,
        changeToReturn: changeToReturn,
        businessName: businessName,
        businessAddress: businessAddress,
        businessPhone: businessPhone,
      ),
      flush: true,
    );
    return file;
  }

  /// Opens the native "Save As" dialog (Storage Access Framework on Android,
  /// the document picker on iOS) so the user picks exactly where the PDF
  /// lands on their device — e.g. Downloads — rather than just sharing it
  /// to another app. Returns true if the user actually saved it somewhere.
  static Future<bool> saveToDevice(File file) async {
    final bytes = await file.readAsBytes();
    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save invoice PDF',
      fileName: file.uri.pathSegments.last,
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
      ShareParams(files: [XFile(file.path)], fileNameOverrides: [file.uri.pathSegments.last]),
    );
  }

  static Uint8List _buildPdf({
    required String invoiceNumber,
    required String customerName,
    required String orderId,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double totalAmount,
    required double amountReceived,
    required double changeToReturn,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
  }) {
    final lines = [
      businessName,
      if (businessAddress.isNotEmpty) businessAddress,
      if (businessPhone.isNotEmpty) 'Tel: $businessPhone',
      'Invoice: $invoiceNumber',
      'Order: $orderId',
      'Customer: $customerName',
      '',
      'Items',
      for (final item in items)
        '${item.name} x${item.quantity}    \$${AppHelperFunctions.getFormattedMoney(item.price * item.quantity)}',
      '',
      'Subtotal: \$${AppHelperFunctions.getFormattedMoney(subtotal)}',
      'Tax: \$${AppHelperFunctions.getFormattedMoney(tax)}',
      'Total: \$${AppHelperFunctions.getFormattedMoney(totalAmount)}',
      'Amount Received: \$${AppHelperFunctions.getFormattedMoney(amountReceived)}',
      'Change to Return: \$${AppHelperFunctions.getFormattedMoney(changeToReturn)}',
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
