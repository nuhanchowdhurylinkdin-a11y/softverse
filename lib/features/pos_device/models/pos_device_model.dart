class PosDeviceModel {
  final String id;
  final String name;
  final String storeId;
  final String? storeName;
  final bool isActivated;

  const PosDeviceModel({
    required this.id,
    required this.name,
    required this.storeId,
    this.storeName,
    required this.isActivated,
  });

  factory PosDeviceModel.fromApi(Map<String, dynamic> json) {
    return PosDeviceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      storeId: json['storeId']?.toString() ?? '',
      storeName: json['storeName']?.toString(),
      isActivated: json['status']?.toString() == 'activated',
    );
  }
}
