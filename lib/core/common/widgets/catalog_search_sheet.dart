import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CatalogSearchEntry {
  final String key;
  final String name;
  final String sku;
  final String barcode;
  final String subtitle;

  const CatalogSearchEntry({
    required this.key,
    required this.name,
    this.sku = '',
    this.barcode = '',
    this.subtitle = '',
  });

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return name.toLowerCase().contains(normalized) ||
        sku.toLowerCase().contains(normalized) ||
        barcode.toLowerCase().contains(normalized);
  }
}

Future<CatalogSearchEntry?> showCatalogSearchSheet({
  required String title,
  required List<CatalogSearchEntry> items,
}) {
  return Get.bottomSheet<CatalogSearchEntry>(
    _CatalogSearchSheet(title: title, items: items),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _CatalogSearchSheet extends StatefulWidget {
  final String title;
  final List<CatalogSearchEntry> items;

  const _CatalogSearchSheet({required this.title, required this.items});

  @override
  State<_CatalogSearchSheet> createState() => _CatalogSearchSheetState();
}

class _CatalogSearchSheetState extends State<_CatalogSearchSheet> {
  Timer? _debounce;
  String _query = '';

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = widget.items.where((item) => item.matches(_query)).toList();
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                onChanged: _onChanged,
                decoration: const InputDecoration(
                  labelText: 'Name, SKU, or barcode',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: matches.isEmpty
                    ? const Center(child: Text('No items found'))
                    : ListView.separated(
                        itemCount: matches.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = matches[index];
                          final details = [
                            if (item.sku.isNotEmpty) 'SKU ${item.sku}',
                            if (item.barcode.isNotEmpty) item.barcode,
                            if (item.subtitle.isNotEmpty) item.subtitle,
                          ].join(' • ');
                          return ListTile(
                            title: Text(item.name),
                            subtitle: details.isEmpty ? null : Text(details),
                            onTap: () => Get.back(result: item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
