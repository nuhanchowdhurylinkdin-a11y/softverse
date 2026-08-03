import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../models/customer_model.dart';

class CustomerController extends GetxController {
  final customer = const CustomerModel(
    name: 'Abs Corporation',
    email: 'abcc@ mail.com',
    phone: '+8801254452300',
    address: '123,green Avenue',
    city: 'Dhaka',
    region: 'Bangladesh',
    postalCode: '1 234',
    country: 'Bangladesh',
    customerCode: 'CUS-10001',
    imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    note: '',
    creditLimit: 18000,
    points: 0,
    visitCount: 10,
    lastVisitDate: '21 Jun 2026',
  ).obs;

  void openEdit() => Get.toNamed(AppRoute.getEditCustomerScreen());

  void openAddCustomer() => Get.toNamed(AppRoute.getAddCustomerScreen());

  void redeemPoints() {}

  void viewPurchaseHistory() {}
}
