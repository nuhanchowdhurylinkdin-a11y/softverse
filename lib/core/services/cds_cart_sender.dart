import 'main_station_server.dart';

class CdsCartSender {
  void update(Map<String, dynamic> cart) =>
      MainStationServer.instance.updateCdsCart(cart);

  void complete(Map<String, dynamic> cart) =>
      MainStationServer.instance.completeCdsCheckout(cart);

  void clear() => MainStationServer.instance.clearCdsCart();
}
