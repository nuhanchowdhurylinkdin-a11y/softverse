enum AppDeviceType { cds, kds }

extension AppDeviceTypeX on AppDeviceType {
  String get label => this == AppDeviceType.cds ? 'CDS' : 'KDS';

  String get ipFieldLabel => this == AppDeviceType.cds
      ? 'Customer Display IP address'
      : 'Kitchen Display IP address';

  String get nameHint =>
      this == AppDeviceType.cds ? 'Enter CDS Name' : 'Enter KDS Name';
}

class AppDeviceModel {
  final String id;
  final AppDeviceType type;
  final String name;
  final String ipAddress;
  final bool isPaired;

  const AppDeviceModel({
    required this.id,
    required this.type,
    required this.name,
    required this.ipAddress,
    required this.isPaired,
  });

  AppDeviceModel copyWith({String? name, String? ipAddress, bool? isPaired}) {
    return AppDeviceModel(
      id: id,
      type: type,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      isPaired: isPaired ?? this.isPaired,
    );
  }
}
