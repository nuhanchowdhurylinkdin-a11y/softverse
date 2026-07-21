import 'package:get/get.dart';

class HomeController extends GetxController {
  final counter = 0.obs;

  void increment() => counter.value++;
  void decrement() {
    if (counter.value > 0) counter.value--;
  }
  void reset() => counter.value = 0;
}
