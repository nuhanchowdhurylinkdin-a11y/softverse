import 'package:get/get.dart';

import '../features/apps/controller/add_app_device_controller.dart';
import '../features/apps/controller/app_device_view_controller.dart';
import '../features/apps/views/screens/add_app_device_screen.dart';
import '../features/apps/views/screens/app_device_list_screen.dart';
import '../features/apps/views/screens/app_device_view_screen.dart';
import '../features/apps/views/screens/apps_menu_screen.dart';
import '../features/auth/views/screens/enter_otp_screen.dart';
import '../features/customer/controller/add_customer_controller.dart';
import '../features/customer/controller/edit_customer_controller.dart';
import '../features/customer/views/screens/add_customer_screen.dart';
import '../features/customer/views/screens/edit_customer_screen.dart';
import '../features/customer/views/screens/view_customer_screen.dart';
import '../features/auth/views/screens/forget_password_screen.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/auth/views/screens/registration_screen.dart';
import '../features/auth/views/screens/reset_password_screen.dart';
import '../features/checkout/views/screens/pending_orders_screen.dart';
import '../features/general/views/screens/general_settings_screen.dart';
import '../features/general/views/screens/home_screen_item_layout_screen.dart';
import '../features/inventory/controller/item_detail_controller.dart';
import '../features/inventory/views/screens/item_detail_screen.dart';
import '../features/invoice/views/screens/invoice_screen.dart';
import '../features/invoice/views/screens/receipt_preview_screen.dart';
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
import '../features/printer/controller/add_printer_controller.dart';
import '../features/printer/views/screens/add_printer_screen.dart';
import '../features/printer/views/screens/printer_detail_screen.dart';
import '../features/printer/views/screens/printer_list_screen.dart';
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
import '../features/tax/controller/add_tax_controller.dart';
import '../features/tax/controller/apply_tax_items_controller.dart';
import '../features/tax/controller/edit_tax_controller.dart';
import '../features/tax/views/screens/add_tax_screen.dart';
import '../features/tax/views/screens/apply_tax_items_screen.dart';
import '../features/tax/views/screens/edit_tax_screen.dart';
import '../features/tax/views/screens/tax_list_screen.dart';
import '../features/tables/controller/add_table_controller.dart';
import '../features/tables/views/screens/add_table_screen.dart';
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
  static String pendingOrdersScreen = "/pendingOrdersScreen";
  static String receiptPreviewScreen = "/receiptPreviewScreen";
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
  static String viewCustomerScreen = "/viewCustomerScreen";
  static String editCustomerScreen = "/editCustomerScreen";
  static String addCustomerScreen = "/addCustomerScreen";
  static String printerListScreen = "/printerListScreen";
  static String printerDetailScreen = "/printerDetailScreen";
  static String addPrinterScreen = "/addPrinterScreen";
  static String appsMenuScreen = "/appsMenuScreen";
  static String appDeviceListScreen = "/appDeviceListScreen";
  static String appDeviceViewScreen = "/appDeviceViewScreen";
  static String addAppDeviceScreen = "/addAppDeviceScreen";
  static String taxListScreen = "/taxListScreen";
  static String editTaxScreen = "/editTaxScreen";
  static String addTaxScreen = "/addTaxScreen";
  static String applyTaxItemsScreen = "/applyTaxItemsScreen";
  static String generalSettingsScreen = "/generalSettingsScreen";
  static String homeScreenItemLayoutScreen = "/homeScreenItemLayoutScreen";
  static String addTableScreen = "/addTableScreen";

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
  static String getPendingOrdersScreen() => pendingOrdersScreen;
  static String getReceiptPreviewScreen() => receiptPreviewScreen;
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
  static String getViewCustomerScreen() => viewCustomerScreen;
  static String getEditCustomerScreen() => editCustomerScreen;
  static String getAddCustomerScreen() => addCustomerScreen;
  static String getPrinterListScreen() => printerListScreen;
  static String getPrinterDetailScreen() => printerDetailScreen;
  static String getAddPrinterScreen() => addPrinterScreen;
  static String getAppsMenuScreen() => appsMenuScreen;
  static String getAppDeviceListScreen() => appDeviceListScreen;
  static String getAppDeviceViewScreen() => appDeviceViewScreen;
  static String getAddAppDeviceScreen() => addAppDeviceScreen;
  static String getTaxListScreen() => taxListScreen;
  static String getEditTaxScreen() => editTaxScreen;
  static String getAddTaxScreen() => addTaxScreen;
  static String getApplyTaxItemsScreen() => applyTaxItemsScreen;
  static String getGeneralSettingsScreen() => generalSettingsScreen;
  static String getHomeScreenItemLayoutScreen() => homeScreenItemLayoutScreen;
  static String getAddTableScreen() => addTableScreen;

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
    GetPage(name: pendingOrdersScreen, page: () => const PendingOrdersScreen()),
    GetPage(
      name: receiptPreviewScreen,
      page: () => const ReceiptPreviewScreen(),
    ),
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
    GetPage(name: viewCustomerScreen, page: () => const ViewCustomerScreen()),
    GetPage(
      name: editCustomerScreen,
      page: () => const EditCustomerScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EditCustomerController>(() => EditCustomerController());
      }),
    ),
    GetPage(
      name: addCustomerScreen,
      page: () => const AddCustomerScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddCustomerController>(() => AddCustomerController());
      }),
    ),
    GetPage(name: printerListScreen, page: () => const PrinterListScreen()),
    GetPage(name: printerDetailScreen, page: () => const PrinterDetailScreen()),
    GetPage(
      name: addPrinterScreen,
      page: () => const AddPrinterScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddPrinterController>(() => AddPrinterController());
      }),
    ),
    GetPage(name: appsMenuScreen, page: () => const AppsMenuScreen()),
    GetPage(name: appDeviceListScreen, page: () => const AppDeviceListScreen()),
    GetPage(
      name: appDeviceViewScreen,
      page: () => const AppDeviceViewScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AppDeviceViewController>(() => AppDeviceViewController());
      }),
    ),
    GetPage(
      name: addAppDeviceScreen,
      page: () => const AddAppDeviceScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddAppDeviceController>(() => AddAppDeviceController());
      }),
    ),
    GetPage(name: taxListScreen, page: () => const TaxListScreen()),
    GetPage(
      name: editTaxScreen,
      page: () => const EditTaxScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EditTaxController>(() => EditTaxController());
      }),
    ),
    GetPage(
      name: addTaxScreen,
      page: () => const AddTaxScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddTaxController>(() => AddTaxController());
      }),
    ),
    GetPage(
      name: applyTaxItemsScreen,
      page: () => const ApplyTaxItemsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ApplyTaxItemsController>(() => ApplyTaxItemsController());
      }),
    ),
    GetPage(
      name: generalSettingsScreen,
      page: () => const GeneralSettingsScreen(),
    ),
    GetPage(
      name: homeScreenItemLayoutScreen,
      page: () => const HomeScreenItemLayoutScreen(),
    ),
    GetPage(
      name: addTableScreen,
      page: () => const AddTableScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddTableController>(() => AddTableController());
      }),
    ),
  ];
}
