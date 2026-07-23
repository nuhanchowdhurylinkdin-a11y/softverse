import 'package:get/get.dart';

import '../features/auth/views/screens/enter_otp_screen.dart';
import '../features/auth/views/screens/forget_password_screen.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/auth/views/screens/registration_screen.dart';
import '../features/auth/views/screens/reset_password_screen.dart';
import '../features/inventory/controller/item_detail_controller.dart';
import '../features/inventory/views/screens/item_detail_screen.dart';
import '../features/invoice/views/screens/invoice_screen.dart';
import '../features/invoice/views/screens/refund_invoice_screen.dart';
import '../features/invoice/views/screens/refund_screen.dart';
import '../features/item/controller/create_item_controller.dart';
import '../features/item/controller/items_menu_controller.dart';
import '../features/item/controller/scan_barcode_controller.dart';
import '../features/item/views/screens/create_item_screen.dart';
import '../features/item/views/screens/items_menu_screen.dart';
import '../features/item/views/screens/scan_barcode_screen.dart';
import '../features/main_nav/views/screens/main_nav_screen.dart';
import '../features/onboarding/views/screens/onboarding_screen.dart';
import '../features/shift/controller/cash_management_controller.dart';
import '../features/shift/controller/close_shift_controller.dart';
import '../features/shift/controller/open_shift_controller.dart';
import '../features/shift/views/screens/cash_management_screen.dart';
import '../features/shift/views/screens/close_shift_screen.dart';
import '../features/shift/views/screens/open_shift_screen.dart';
import '../features/shift/views/screens/shift_list_screen.dart';
import '../features/shift/views/screens/shift_management_screen.dart';
import '../features/shift/views/screens/shift_report_screen.dart';
import '../features/splash/views/screens/splash_screen.dart';
import '../features/walkthrough/views/screens/feature_settings_screen.dart';
import '../features/walkthrough/views/screens/walkthrough_screen.dart';

class AppRoute {
  static String splashScreen = "/splashScreen";
  static String onboardingScreen = "/onboardingScreen";
  static String loginScreen = "/loginScreen";
  static String registrationScreen = "/registrationScreen";
  static String forgetPasswordScreen = "/forgetPasswordScreen";
  static String enterOtpScreen = "/enterOtpScreen";
  static String resetPasswordScreen = "/resetPasswordScreen";
  static String walkthroughScreen = "/walkthroughScreen";
  static String featureSettingsScreen = "/featureSettingsScreen";
  static String homeScreen = "/homeScreen";
  static String invoiceScreen = "/invoiceScreen";
  static String refundScreen = "/refundScreen";
  static String refundInvoiceScreen = "/refundInvoiceScreen";
  static String itemDetailScreen = "/itemDetailScreen";
  static String shiftManagementScreen = "/shiftManagementScreen";
  static String shiftListScreen = "/shiftListScreen";
  static String shiftReportScreen = "/shiftReportScreen";
  static String cashManagementScreen = "/cashManagementScreen";
  static String closeShiftScreen = "/closeShiftScreen";
  static String openShiftScreen = "/openShiftScreen";
  static String itemsMenuScreen = "/itemsMenuScreen";
  static String createItemScreen = "/createItemScreen";
  static String scanBarcodeScreen = "/scanBarcodeScreen";

  static String getSplashScreen() => splashScreen;
  static String getOnboardingScreen() => onboardingScreen;
  static String getLoginScreen() => loginScreen;
  static String getRegistrationScreen() => registrationScreen;
  static String getForgetPasswordScreen() => forgetPasswordScreen;
  static String getEnterOtpScreen() => enterOtpScreen;
  static String getResetPasswordScreen() => resetPasswordScreen;
  static String getWalkthroughScreen() => walkthroughScreen;
  static String getFeatureSettingsScreen() => featureSettingsScreen;
  static String getHomeScreen() => homeScreen;
  static String getInvoiceScreen() => invoiceScreen;
  static String getRefundScreen() => refundScreen;
  static String getRefundInvoiceScreen() => refundInvoiceScreen;
  static String getItemDetailScreen() => itemDetailScreen;
  static String getShiftManagementScreen() => shiftManagementScreen;
  static String getShiftListScreen() => shiftListScreen;
  static String getShiftReportScreen() => shiftReportScreen;
  static String getCashManagementScreen() => cashManagementScreen;
  static String getCloseShiftScreen() => closeShiftScreen;
  static String getOpenShiftScreen() => openShiftScreen;
  static String getItemsMenuScreen() => itemsMenuScreen;
  static String getCreateItemScreen() => createItemScreen;
  static String getScanBarcodeScreen() => scanBarcodeScreen;

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: onboardingScreen, page: () => const OnboardingScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: registrationScreen, page: () => const RegistrationScreen()),
    GetPage(
      name: forgetPasswordScreen,
      page: () => const ForgetPasswordScreen(),
    ),
    GetPage(name: enterOtpScreen, page: () => const EnterOtpScreen()),
    GetPage(name: resetPasswordScreen, page: () => const ResetPasswordScreen()),
    GetPage(name: walkthroughScreen, page: () => const WalkthroughScreen()),
    GetPage(
      name: featureSettingsScreen,
      page: () => const FeatureSettingsScreen(),
    ),
    GetPage(name: homeScreen, page: () => const MainNavScreen()),
    GetPage(name: invoiceScreen, page: () => const InvoiceScreen()),
    GetPage(name: refundScreen, page: () => const RefundScreen()),
    GetPage(name: refundInvoiceScreen, page: () => const RefundInvoiceScreen()),
    GetPage(
      name: itemDetailScreen,
      page: () => const ItemDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ItemDetailController>(() => ItemDetailController());
      }),
    ),
    GetPage(
      name: shiftManagementScreen,
      page: () => const ShiftManagementScreen(),
    ),
    GetPage(name: shiftListScreen, page: () => const ShiftListScreen()),
    GetPage(name: shiftReportScreen, page: () => const ShiftReportScreen()),
    GetPage(
      name: cashManagementScreen,
      page: () => const CashManagementScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CashManagementController>(() => CashManagementController());
      }),
    ),
    GetPage(
      name: closeShiftScreen,
      page: () => const CloseShiftScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CloseShiftController>(() => CloseShiftController());
      }),
    ),
    GetPage(
      name: openShiftScreen,
      page: () => const OpenShiftScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OpenShiftController>(() => OpenShiftController());
      }),
    ),
    GetPage(
      name: itemsMenuScreen,
      page: () => const ItemsMenuScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ItemsMenuController>(() => ItemsMenuController());
      }),
    ),
    GetPage(
      name: createItemScreen,
      page: () => const CreateItemScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateItemController>(() => CreateItemController());
      }),
    ),
    GetPage(
      name: scanBarcodeScreen,
      page: () => const ScanBarcodeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ScanBarcodeController>(() => ScanBarcodeController());
      }),
    ),
  ];
}
