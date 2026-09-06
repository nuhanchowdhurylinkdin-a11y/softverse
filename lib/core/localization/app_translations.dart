import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// GetX translation table. English strings are used as the lookup key
/// (via `.tr`), so an English entry is just the identity mapping and no
/// separate key scheme is needed.
///
/// Coverage is intentionally scoped to the app's highest-traffic, always
/// visible surfaces (nav drawer, More menu, General settings) rather than
/// every string in the app — extend this map screen-by-screen as more
/// screens adopt `.tr`.
class AppTranslations extends Translations {
  static const fallbackLocale = Locale('en', 'US');
  static const supportedLocales = [Locale('en', 'US'), Locale('bn', 'BD')];

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': _en,
    'bn_BD': _bn,
  };

  static const Map<String, String> _en = {
    // Nav drawer
    'Home': 'Home',
    'Checkout': 'Checkout',
    'Transaction': 'Transaction',
    'Inventory': 'Inventory',
    'More': 'More',
    // More screen
    'Shift': 'Shift',
    'Item': 'Item',
    'Tables': 'Tables',
    'Customer': 'Customer',
    'Settings': 'Settings',
    'Printer': 'Printer',
    'Apps': 'Apps',
    'General': 'General',
    'Taxes': 'Taxes',
    'Back Office': 'Back Office',
    'Apps Integration': 'Apps Integration',
    'Supports': 'Supports',
    'Log out': 'Log out',
    // General settings screen
    'Use camera to scan barcodes': 'Use camera to scan barcodes',
    'Home screen item layout': 'Home screen item layout',
    'Feature': 'Feature',
    'Language': 'Language',
    // Language picker
    'Use device settings': 'Use device settings',
    'English': 'English',
    'Bengali': 'Bengali',
  };

  static const Map<String, String> _bn = {
    // Nav drawer
    'Home': 'হোম',
    'Checkout': 'চেকআউট',
    'Transaction': 'ট্রানজেকশন',
    'Inventory': 'ইনভেন্টরি',
    'More': 'আরও',
    // More screen
    'Shift': 'শিফট',
    'Item': 'আইটেম',
    'Tables': 'টেবিল',
    'Customer': 'কাস্টমার',
    'Settings': 'সেটিংস',
    'Printer': 'প্রিন্টার',
    'Apps': 'অ্যাপস',
    'General': 'সাধারণ',
    'Taxes': 'ট্যাক্স',
    'Back Office': 'ব্যাক অফিস',
    'Apps Integration': 'অ্যাপ ইন্টিগ্রেশন',
    'Supports': 'সাপোর্ট',
    'Log out': 'লগ আউট',
    // General settings screen
    'Use camera to scan barcodes': 'বারকোড স্ক্যান করতে ক্যামেরা ব্যবহার করুন',
    'Home screen item layout': 'হোম স্ক্রিন আইটেম লেআউট',
    'Feature': 'ফিচার',
    'Language': 'ভাষা',
    // Language picker
    'Use device settings': 'ডিভাইসের সেটিংস ব্যবহার করুন',
    'English': 'ইংরেজি',
    'Bengali': 'বাংলা',
  };
}
