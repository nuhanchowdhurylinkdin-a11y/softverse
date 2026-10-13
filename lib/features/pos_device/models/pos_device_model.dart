class PosDeviceModel {
  final String id;
  final String name;
  final String storeId;

  /// Another till is signed in as this device right now.
  final bool inUse;

  const PosDeviceModel({
    required this.id,
    required this.name,
    required this.storeId,
    this.inUse = false,
  });

  factory PosDeviceModel.fromApi(Map<String, dynamic> json) {
    return PosDeviceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      storeId: json['storeId']?.toString() ?? '',
      inUse: json['inUse'] == true,
    );
  }
}
