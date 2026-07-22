import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final int stockCount;
  final IconData icon;

  const Product({
    required this.name,
    required this.price,
    required this.stockCount,
    required this.icon,
  });
}
