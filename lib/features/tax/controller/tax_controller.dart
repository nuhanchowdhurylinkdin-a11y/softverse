import 'package:get/get.dart';

import '../models/tax_model.dart';

class TaxController extends GetxController {
  final taxes = <TaxModel>[
    TaxModel(
      id: 'tax-1',
      name: 'VAT',
      ratePercent: 7.5,
      type: TaxType.addedAtCheckout,
      appliedItemIds: List.generate(8, (i) => 'item-$i'),
    ),
    TaxModel(
      id: 'tax-2',
      name: 'VAT',
      ratePercent: 10,
      type: TaxType.addedAtCheckout,
      appliedItemIds: List.generate(8, (i) => 'item-$i'),
    ),
    TaxModel(
      id: 'tax-3',
      name: 'VAT',
      ratePercent: 15,
      type: TaxType.includedInPrice,
      appliedItemIds: List.generate(8, (i) => 'item-$i'),
    ),
  ].obs;

  int _indexOf(String id) => taxes.indexWhere((t) => t.id == id);

  TaxModel? taxById(String id) => taxes.firstWhereOrNull((t) => t.id == id);

  void addTax(TaxModel tax) => taxes.add(tax);

  void removeTax(String id) => taxes.removeWhere((t) => t.id == id);

  void updateTax(TaxModel updated) {
    final index = _indexOf(updated.id);
    if (index == -1) return;
    taxes[index] = updated;
  }
}
