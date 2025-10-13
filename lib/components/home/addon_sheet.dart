import 'package:flutter/material.dart';

import '../../models/raw_data.dart';

class AddOnSheet extends StatefulWidget {
  final ListElement product;
  final List<AddOn> availableAddOns;

  const AddOnSheet({required this.product, required this.availableAddOns});

  @override
  State<AddOnSheet> createState() => _AddOnSheetState();
}

class _AddOnSheetState extends State<AddOnSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total =
        widget.product.price +
        widget.availableAddOns
            .where((e) => _selected.contains(e.name))
            .fold(0, (p, e) => p + e.price);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Customize ${widget.product.title}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: widget.availableAddOns.map((addOn) {
                  return CheckboxListTile(
                    title: Text(addOn.name),
                    subtitle: Text('+ \$${addOn.price}'),
                    value: _selected.contains(addOn.name),
                    onChanged: (v) => setState(() {
                      v!
                          ? _selected.add(addOn.name)
                          : _selected.remove(addOn.name);
                    }),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final selectedAddOns = widget.availableAddOns
                    .where((e) => _selected.contains(e.name))
                    .toList();
                Navigator.pop(context, selectedAddOns);
              },
              child: Text('Add to Cart | \$${total.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}
