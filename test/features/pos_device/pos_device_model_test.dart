import 'package:flutter_test/flutter_test.dart';
import 'package:softverse/features/pos_device/models/pos_device_model.dart';

void main() {
  test('parses an activated device from the API response', () {
    final device = PosDeviceModel.fromApi({
      'id': 'device-a',
      'name': 'POS 01',
      'storeId': 'store-a',
      'storeName': 'Downtown',
      'status': 'activated',
      'statusLabel': 'Activated',
    });

    expect(device.id, 'device-a');
    expect(device.name, 'POS 01');
    expect(device.storeName, 'Downtown');
    expect(device.isActivated, isTrue);
  });

  test('a not-yet-activated device is not marked activated', () {
    final device = PosDeviceModel.fromApi({
      'id': 'device-b',
      'name': 'POS 02',
      'storeId': 'store-a',
      'status': 'not_activated',
    });

    expect(device.isActivated, isFalse);
  });
}
