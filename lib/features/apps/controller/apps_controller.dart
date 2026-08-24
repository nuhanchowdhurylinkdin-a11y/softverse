import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/main_station_server.dart';
import '../models/app_device_model.dart';

/// Live-connected KDS/CDS devices — not a saved roster. A device appears
/// here only while its WebSocket connection to this station is open.
class AppsController extends GetxController {
  final connectedCdsIps = <String>[].obs;
  final connectedKdsIps = <String>[].obs;

  Timer? _poller;

  @override
  void onInit() {
    super.onInit();
    _refresh();
    _poller = Timer.periodic(const Duration(seconds: 2), (_) => _refresh());
  }

  @override
  void onClose() {
    _poller?.cancel();
    super.onClose();
  }

  List<String> connectedIpsOfType(AppDeviceType type) =>
      type == AppDeviceType.cds ? connectedCdsIps : connectedKdsIps;

  void _refresh() {
    connectedCdsIps.assignAll(MainStationServer.instance.connectedCdsIps);
    connectedKdsIps.assignAll(MainStationServer.instance.connectedKdsIps);
  }
}
