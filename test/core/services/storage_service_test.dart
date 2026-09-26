import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softverse/core/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('POS device selection survives logout, like theme and language do', () async {
    // Which physical till this is belongs to the device, not the login -
    // wiping it on every logout would force re-picking it for every
    // cashier shift change on the same terminal.
    await StorageService.saveUserSession(
      id: 'user-a',
      fullName: 'Owner',
      email: 'owner@example.com',
      accessToken: 'token',
      refreshToken: 'refresh',
    );
    await StorageService.setPosDevice(id: 'device-a', name: 'POS 01');

    expect(StorageService.posDeviceId, 'device-a');
    expect(StorageService.posDeviceName, 'POS 01');

    await StorageService.logoutUser();

    expect(StorageService.posDeviceId, 'device-a');
    expect(StorageService.posDeviceName, 'POS 01');
    expect(StorageService.accessToken, isNull);
  });

  test('clearPosDevice removes the stored selection', () async {
    await StorageService.setPosDevice(id: 'device-a', name: 'POS 01');
    await StorageService.clearPosDevice();

    expect(StorageService.posDeviceId, isNull);
    expect(StorageService.posDeviceName, isNull);
  });
}
