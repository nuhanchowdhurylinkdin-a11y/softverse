enum AppDeviceType { cds, kds }

extension AppDeviceTypeX on AppDeviceType {
  String get label => this == AppDeviceType.cds ? 'CDS' : 'KDS';
}
