import 'main_station_server.dart';

class KdsOrderSender {
  Future<bool> send(Map<String, dynamic> order) async {
    return MainStationServer.instance.addKdsOrder(order);
  }

  Future<bool> complete(String id) async {
    return MainStationServer.instance.completeKdsOrder(id);
  }

  Future<bool> completeAny(Iterable<String?> ids) async {
    return MainStationServer.instance.completeKdsOrderByKeys(ids);
  }
}
