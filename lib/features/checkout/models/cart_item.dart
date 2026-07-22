import 'package:flutter/material.dart';

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
  final String name;
  final double price;
  final IconData icon;
  final int quantity;
  final BundleInfo? bundle;

  const CartItem({
    required this.name,
    required this.price,
    required this.icon,
    required this.quantity,
    this.bundle,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      name: name,
      price: price,
      icon: icon,
      quantity: quantity ?? this.quantity,
      bundle: bundle,
    );
  }
}
