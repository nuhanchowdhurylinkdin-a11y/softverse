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

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      printerModel: json['printerModel']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Receipt Printer',
      connectionType: json['connectionType']?.toString() ?? 'Bluetooth',
      macAddress: json['macAddress']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      closeTime: json['closeTime']?.toString() ?? '',
      isConnected: json['isConnected'] == true,
      isDefault: json['isDefault'] == true,
      printReceiptAndBills: json['printReceiptAndBills'] != false,
      printOrders: json['printOrders'] == true,
      paperSize: json['paperSize']?.toString() ?? '80mm',
      printDensity: json['printDensity']?.toString() ?? 'Medium',
      autoCut: json['autoCut'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'printerModel': printerModel,
      'category': category,
      'connectionType': connectionType,
      'macAddress': macAddress,
      'startTime': startTime,
      'closeTime': closeTime,
      'isConnected': isConnected,
      'isDefault': isDefault,
      'printReceiptAndBills': printReceiptAndBills,
      'printOrders': printOrders,
      'paperSize': paperSize,
      'printDensity': printDensity,
      'autoCut': autoCut,
    };
  }

  PrinterModel copyWith({
    String? id,
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
      id: id ?? this.id,
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
