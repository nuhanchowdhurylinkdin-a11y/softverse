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
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('bn', 'BD'),
    Locale('hi', 'IN'),
    Locale('ar', 'SA'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': _en,
    'bn_BD': _bn,
    'hi_IN': _hi,
    'ar_SA': _ar,
    'es_ES': _es,
    'fr_FR': _fr,
  };

  /// Maps a [kLanguageOptions] entry to the [Locale] it should apply.
  /// "Use device settings" (or anything unrecognized) falls back to the
  /// device's own locale, or [fallbackLocale] if that isn't supported.
  static Locale localeForLanguageName(String name) => switch (name) {
    'English' => fallbackLocale,
    'Bengali' => const Locale('bn', 'BD'),
    'Hindi' => const Locale('hi', 'IN'),
    'Arabic' => const Locale('ar', 'SA'),
    'Spanish' => const Locale('es', 'ES'),
    'French' => const Locale('fr', 'FR'),
    _ => Get.deviceLocale ?? fallbackLocale,
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
    'Hindi': 'Hindi',
    'Arabic': 'Arabic',
    'Spanish': 'Spanish',
    'French': 'French',
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
    'Hindi': 'হিন্দি',
    'Arabic': 'আরবি',
    'Spanish': 'স্প্যানিশ',
    'French': 'ফরাসি',
  };

  static const Map<String, String> _hi = {
    // Nav drawer
    'Home': 'होम',
    'Checkout': 'चेकआउट',
    'Transaction': 'लेन-देन',
    'Inventory': 'इन्वेंटरी',
    'More': 'अधिक',
    // More screen
    'Shift': 'शिफ्ट',
    'Item': 'आइटम',
    'Tables': 'टेबल',
    'Customer': 'ग्राहक',
    'Settings': 'सेटिंग्स',
    'Printer': 'प्रिंटर',
    'Apps': 'ऐप्स',
    'General': 'सामान्य',
    'Taxes': 'कर',
    'Back Office': 'बैक ऑफिस',
    'Apps Integration': 'ऐप एकीकरण',
    'Supports': 'सहायता',
    'Log out': 'लॉग आउट',
    // General settings screen
    'Use camera to scan barcodes': 'बारकोड स्कैन करने के लिए कैमरा का उपयोग करें',
    'Home screen item layout': 'होम स्क्रीन आइटम लेआउट',
    'Feature': 'फीचर',
    'Language': 'भाषा',
    // Language picker
    'Use device settings': 'डिवाइस सेटिंग का उपयोग करें',
    'English': 'अंग्रेज़ी',
    'Bengali': 'बंगाली',
    'Hindi': 'हिन्दी',
    'Arabic': 'अरबी',
    'Spanish': 'स्पेनिश',
    'French': 'फ्रेंच',
  };

  static const Map<String, String> _ar = {
    // Nav drawer
    'Home': 'الرئيسية',
    'Checkout': 'الدفع',
    'Transaction': 'المعاملات',
    'Inventory': 'المخزون',
    'More': 'المزيد',
    // More screen
    'Shift': 'الوردية',
    'Item': 'الصنف',
    'Tables': 'الطاولات',
    'Customer': 'العميل',
    'Settings': 'الإعدادات',
    'Printer': 'الطابعة',
    'Apps': 'التطبيقات',
    'General': 'عام',
    'Taxes': 'الضرائب',
    'Back Office': 'المكتب الخلفي',
    'Apps Integration': 'تكامل التطبيقات',
    'Supports': 'الدعم',
    'Log out': 'تسجيل الخروج',
    // General settings screen
    'Use camera to scan barcodes': 'استخدم الكاميرا لمسح الباركود',
    'Home screen item layout': 'تخطيط عناصر الشاشة الرئيسية',
    'Feature': 'الميزة',
    'Language': 'اللغة',
    // Language picker
    'Use device settings': 'استخدام إعدادات الجهاز',
    'English': 'الإنجليزية',
    'Bengali': 'البنغالية',
    'Hindi': 'الهندية',
    'Arabic': 'العربية',
    'Spanish': 'الإسبانية',
    'French': 'الفرنسية',
  };

  static const Map<String, String> _es = {
    // Nav drawer
    'Home': 'Inicio',
    'Checkout': 'Pagar',
    'Transaction': 'Transacción',
    'Inventory': 'Inventario',
    'More': 'Más',
    // More screen
    'Shift': 'Turno',
    'Item': 'Artículo',
    'Tables': 'Mesas',
    'Customer': 'Cliente',
    'Settings': 'Configuración',
    'Printer': 'Impresora',
    'Apps': 'Aplicaciones',
    'General': 'General',
    'Taxes': 'Impuestos',
    'Back Office': 'Back Office',
    'Apps Integration': 'Integración de aplicaciones',
    'Supports': 'Soporte',
    'Log out': 'Cerrar sesión',
    // General settings screen
    'Use camera to scan barcodes':
        'Usar la cámara para escanear códigos de barras',
    'Home screen item layout':
        'Diseño de artículos de la pantalla de inicio',
    'Feature': 'Función',
    'Language': 'Idioma',
    // Language picker
    'Use device settings': 'Usar la configuración del dispositivo',
    'English': 'Inglés',
    'Bengali': 'Bengalí',
    'Hindi': 'Hindi',
    'Arabic': 'Árabe',
    'Spanish': 'Español',
    'French': 'Francés',
  };

  static const Map<String, String> _fr = {
    // Nav drawer
    'Home': 'Accueil',
    'Checkout': 'Paiement',
    'Transaction': 'Transaction',
    'Inventory': 'Inventaire',
    'More': 'Plus',
    // More screen
    'Shift': 'Poste',
    'Item': 'Article',
    'Tables': 'Tables',
    'Customer': 'Client',
    'Settings': 'Paramètres',
    'Printer': 'Imprimante',
    'Apps': 'Applications',
    'General': 'Général',
    'Taxes': 'Taxes',
    'Back Office': 'Back Office',
    'Apps Integration': "Intégration d'applications",
    'Supports': 'Support',
    'Log out': 'Déconnexion',
    // General settings screen
    'Use camera to scan barcodes':
        'Utiliser l\'appareil photo pour scanner les codes-barres',
    'Home screen item layout':
        "Disposition des articles de l'écran d'accueil",
    'Feature': 'Fonctionnalité',
    'Language': 'Langue',
    // Language picker
    'Use device settings': "Utiliser les paramètres de l'appareil",
    'English': 'Anglais',
    'Bengali': 'Bengali',
    'Hindi': 'Hindi',
    'Arabic': 'Arabe',
    'Spanish': 'Espagnol',
    'French': 'Français',
  };
}
