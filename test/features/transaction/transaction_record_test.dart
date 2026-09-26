import 'package:flutter_test/flutter_test.dart';
import 'package:softverse/features/transaction/models/transaction_record.dart';

void main() {
  group('TransactionRecord due-paid-off display', () {
    test('still outstanding due sale shows the normal due badge', () {
      final record = TransactionRecord.fromApi({
        'id': 'order-a',
        'paymentMethod': 'due',
        'status': 'completed',
        'totalAmount': '200.00',
        'amountDue': '60.00',
      });

      expect(record.isDuePaidOff, isFalse);
      expect(record.displayLabel, 'Due Payment');
    });

    test('a due sale fully collected shows as paid instead', () {
      // Regression: the transaction list kept showing "Due Payment" forever
      // even after the whole balance was collected, since paymentMethod
      // itself never changes (it's still historically a credit sale).
      final record = TransactionRecord.fromApi({
        'id': 'order-a',
        'paymentMethod': 'due',
        'status': 'completed',
        'totalAmount': '200.00',
        'amountDue': '0.00',
      });

      expect(record.isDuePaidOff, isTrue);
      expect(record.displayLabel, 'Paid (was due)');
    });

    test('a cash sale is never treated as a paid-off due sale', () {
      final record = TransactionRecord.fromApi({
        'id': 'order-a',
        'paymentMethod': 'cash',
        'status': 'completed',
        'totalAmount': '200.00',
        'amountDue': '0.00',
      });

      expect(record.isDuePaidOff, isFalse);
      expect(record.displayLabel, 'Cash Payment');
    });
  });
}
