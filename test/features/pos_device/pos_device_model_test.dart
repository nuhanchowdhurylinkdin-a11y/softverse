import 'package:flutter_test/flutter_test.dart';
import 'package:softverse/features/pos_device/models/pos_device_model.dart';

void main() {
  test('parses a POS device from the login picker endpoint', () {
    final device = PosDeviceModel.fromApi({
      'id': 'pos-1',
      'name': 'Counter 1',
      'storeId': 'store-1',
      'inUse': true,
    });

    expect(device.id, 'pos-1');
    expect(device.name, 'Counter 1');
    expect(device.storeId, 'store-1');
    expect(device.inUse, isTrue);
  });

  test('a device is free unless the server says otherwise', () {
    final device = PosDeviceModel.fromApi({'id': 'pos-2', 'name': 'Counter 2'});

    expect(device.inUse, isFalse);
  });
}
