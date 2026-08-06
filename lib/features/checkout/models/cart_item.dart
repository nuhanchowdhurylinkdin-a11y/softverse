class BundleInfo {
  final String name;
  final double price;
  final String discountLabel;
  final double discountAmount;
  final double subtotal;

  const BundleInfo({
    required this.name,
    required this.price,
    required this.discountLabel,
    required this.discountAmount,
    required this.subtotal,
  });
}

class CartItem {
  final String? itemId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  final BundleInfo? bundle;

  const CartItem({
    this.itemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    this.bundle,
  });

  double get lineSubtotal => (bundle?.subtotal ?? price) * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      itemId: itemId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      bundle: bundle,
    );
  }
}
