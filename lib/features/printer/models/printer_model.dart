class PrinterModel {
  final String id;
  final String name;
  final String printerModel;
  final String category;
  final String connectionType;
  final String macAddress;
  final String startTime;
  final String closeTime;
  final bool isConnected;
  final bool isDefault;
  final bool printReceiptAndBills;
  final bool printOrders;
  final String paperSize;
  final String printDensity;
  final bool autoCut;

  const PrinterModel({
    required this.id,
    required this.name,
    required this.printerModel,
    required this.category,
    required this.connectionType,
    required this.macAddress,
    required this.startTime,
    required this.closeTime,
    required this.isConnected,
    required this.isDefault,
    required this.printReceiptAndBills,
    required this.printOrders,
    required this.paperSize,
    required this.printDensity,
    required this.autoCut,
  });

  PrinterModel copyWith({
    String? name,
    String? printerModel,
    String? category,
    String? connectionType,
    String? macAddress,
    String? startTime,
    String? closeTime,
    bool? isConnected,
    bool? isDefault,
    bool? printReceiptAndBills,
    bool? printOrders,
    String? paperSize,
    String? printDensity,
    bool? autoCut,
  }) {
    return PrinterModel(
      id: id,
      name: name ?? this.name,
      printerModel: printerModel ?? this.printerModel,
      category: category ?? this.category,
      connectionType: connectionType ?? this.connectionType,
      macAddress: macAddress ?? this.macAddress,
      startTime: startTime ?? this.startTime,
      closeTime: closeTime ?? this.closeTime,
      isConnected: isConnected ?? this.isConnected,
      isDefault: isDefault ?? this.isDefault,
      printReceiptAndBills: printReceiptAndBills ?? this.printReceiptAndBills,
      printOrders: printOrders ?? this.printOrders,
      paperSize: paperSize ?? this.paperSize,
      printDensity: printDensity ?? this.printDensity,
      autoCut: autoCut ?? this.autoCut,
    );
  }
}
