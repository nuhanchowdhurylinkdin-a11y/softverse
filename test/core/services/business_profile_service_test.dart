import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softverse/core/services/business_profile_service.dart';
import 'package:softverse/core/services/offline_database_service.dart';
import 'package:softverse/core/services/storage_service.dart';

void main() {
  late Directory databaseDirectory;

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'BASE_URL=https://phase-one.test');
    databaseDirectory = await Directory.systemTemp.createTemp(
      'softverse_business_profile_test_',
    );
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await OfflineDatabaseService.init(
      testPath: databaseDirectory.path,
      boxSuffix: '_business_profile_test',
    );
    await StorageService.saveUserSession(
      id: 'user-id',
      fullName: 'Owner',
      email: 'owner@example.com',
      accessToken: 'token',
      refreshToken: 'refresh',
      role: 'owner',
      businessId: 'business-id',
      permissions: const [],
    );
  });

  tearDownAll(() async {
    await OfflineDatabaseService.closeForTesting();
    await databaseDirectory.delete(recursive: true);
  });

  test('falls back to the generic name when nothing has been fetched yet', () async {
    expect(BusinessProfileService.name, 'Softverse POS');
    expect(BusinessProfileService.address, '');
    expect(BusinessProfileService.phone, '');
    expect(BusinessProfileService.logoUrl, '');
  });

  test('reads the merchant\'s real name, address, and phone once cached', () async {
    await OfflineDatabaseService.saveCache('business_profile', {
      'businessName': 'Louis Cafe',
      'businessAddress': '12 Main St',
      'businessPhone': '+1 555-0100',
      'businessLogoUrl': null,
    });

    expect(BusinessProfileService.name, 'Louis Cafe');
    expect(BusinessProfileService.address, '12 Main St');
    expect(BusinessProfileService.phone, '+1 555-0100');
    expect(BusinessProfileService.logoUrl, '');
  });

  test('falls back to the generic name for a blank cached name', () async {
    await OfflineDatabaseService.saveCache('business_profile', {
      'businessName': '   ',
    });

    expect(BusinessProfileService.name, 'Softverse POS');
  });

  test('reads receipt settings header/footer once cached', () async {
    await OfflineDatabaseService.saveCache('business_profile', {
      'businessName': 'Louis Cafe',
      'receiptHeader': 'Welcome!',
      'receiptFooter': 'See you again',
    });

    expect(BusinessProfileService.header, 'Welcome!');
    expect(BusinessProfileService.footer, 'See you again');
  });

  test(
    'prefers the receipt settings logo over the business profile logo',
    () async {
      await OfflineDatabaseService.saveCache('business_profile', {
        'businessName': 'Louis Cafe',
        'businessLogoUrl': '/media/uploads/profile-logo.png',
        'printedReceiptLogoUrl': '/media/uploads/receipt-logo.png',
      });

      expect(BusinessProfileService.logoUrl, contains('receipt-logo.png'));
    },
  );

  test('falls back to the business profile logo with no receipt logo set', () async {
    await OfflineDatabaseService.saveCache('business_profile', {
      'businessName': 'Louis Cafe',
      'businessLogoUrl': '/media/uploads/profile-logo.png',
      'printedReceiptLogoUrl': null,
    });

    expect(BusinessProfileService.logoUrl, contains('profile-logo.png'));
  });

  test(
    'stays logo-free once the printed-receipt logo was explicitly removed',
    () async {
      // Regression: removing the logo on the dashboard kept coming back
      // because an unconfigured logo and a removed one looked identical
      // (both null) without this flag to tell them apart.
      await OfflineDatabaseService.saveCache('business_profile', {
        'businessName': 'Louis Cafe',
        'businessLogoUrl': '/media/uploads/profile-logo.png',
        'printedReceiptLogoUrl': null,
        'printedReceiptLogoRemoved': true,
      });

      expect(BusinessProfileService.logoUrl, '');
    },
  );
}
