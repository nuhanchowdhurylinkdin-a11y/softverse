import 'package:get/get.dart';

import '../features/auth/views/screens/enter_otp_screen.dart';
import '../features/auth/views/screens/forget_password_screen.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/auth/views/screens/registration_screen.dart';
import '../features/auth/views/screens/reset_password_screen.dart';
import '../features/invoice/views/screens/invoice_screen.dart';
import '../features/invoice/views/screens/refund_invoice_screen.dart';
import '../features/invoice/views/screens/refund_screen.dart';
import '../features/main_nav/views/screens/main_nav_screen.dart';
import '../features/onboarding/views/screens/onboarding_screen.dart';
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
    GetPage(
      name: refundInvoiceScreen,
      page: () => const RefundInvoiceScreen(),
    ),
  ];
}
