import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../utils/locale_utils.dart';
import './home_product_card.dart';
import '/config/routes.dart';
import '/database/data_io.dart';
import '/models/raw_data.dart';

class ProductList extends StatefulWidget {
  final String? categoryId;

  const ProductList({super.key, this.categoryId});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late Future<List<ListElement>> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProducts();
  }

  @override
  void didUpdateWidget(ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      _productFuture = _fetchProducts();
    }
  }

  Future<List<ListElement>> _fetchProducts() {
    return widget.categoryId != null
        ? DataIO.fetchListsByCategory(widget.categoryId!)
        : Future.value([]);
  }

  void _retry() {
    setState(() {
      _productFuture = _fetchProducts();
    });
  }

  Future<void> _addToCartWithoutAddOns(ListElement product) async {
    try {
      final cartItem = CartItem(
        id: product.id,
        thumbnail: product.thumbnail,
        title: product.title,
        addOns: [],
        note: '',
        totalPrice: product.price,
        times: 1,
      );
      await DataIO.addToCart(cartItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.title} added to cart for \$${product.price.toStringAsFixed(2)}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
    }
  }

  Future<void> _showAddOnBottomSheet(ListElement product) async {
    final List<AddOn> availableAddOns = await DataIO.fetchAddOns(
      product.addOn.isNotEmpty ? product.addOn : null,
    );
    final Set<String> selectedAddOns = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Allows SafeArea to handle edges
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          top: false, // No need for top padding since it's a bottom sheet
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              int totalPrice = product.price;
              for (String addOnName in selectedAddOns) {
                final addOn = availableAddOns.firstWhere(
                  (ao) => ao.name == addOnName,
                  orElse: () => AddOn(name: '', type: '', price: 0),
                );
                totalPrice += addOn.price;
              }

              return DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                expand: false,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      // Used surfaceContainerHigh for a modern, elevated look
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Customize ${product.title}', // Updated title for better UX
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          ),
                          const Divider(
                            height: 24,
                          ), // Added divider for separation
                          if (availableAddOns.isEmpty)
                            const Text(
                              'No add-ons available for this item.', // Clarified message
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            // Added title for add-ons list
                            Text(
                              'Available Add-ons (Optional)',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true,
                              itemCount: availableAddOns.length,
                              itemBuilder: (context, index) {
                                final addOn = availableAddOns[index];
                                return CheckboxListTile(
                                  contentPadding:
                                      EdgeInsets.zero, // Modern look
                                  title: Text(addOn.name),
                                  subtitle: Text(
                                    '+ \$${addOn.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  value: selectedAddOns.contains(addOn.name),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedAddOns.add(addOn.name);
                                      } else {
                                        selectedAddOns.remove(addOn.name);
                                      }
                                    });
                                  },
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Action buttons area
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Changed TextButton to a modern OutlinedButton for visibility
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8), // Added spacing
                              Expanded(
                                child: ElevatedButton(
                                  // FIX: The button is now always enabled, regardless of selectedAddOns.isEmpty
                                  onPressed: () async {
                                    try {
                                      final cartItem = CartItem(
                                        id: product.id,
                                        thumbnail: product.thumbnail,
                                        title: product.title,
                                        addOns: selectedAddOns
                                            .map((name) {
                                              final addOn = availableAddOns
                                                  .firstWhere(
                                                    (ao) => ao.name == name,
                                                    orElse: () => AddOn(
                                                      name: '',
                                                      type: '',
                                                      price: 0,
                                                    ),
                                                  );
                                              return {
                                                'name': addOn.name,
                                                'price': addOn.price,
                                              };
                                            })
                                            .where(
                                              (addOn) => addOn['name'] != '',
                                            )
                                            .toList(),
                                        note: '',
                                        totalPrice: totalPrice,
                                        times: 1,
                                      );
                                      await DataIO.addToCart(cartItem);
                                      Navigator.pop(
                                        context,
                                      ); // Close the bottom sheet
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${product.title} added to cart for \$${totalPrice.toStringAsFixed(2)}',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to add to cart: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16, // Increased padding
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4, // Subtle elevation
                                  ),
                                  child: Text(
                                    // Display the total price on the button
                                    'Add to Cart | \$${totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Bottom padding
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No category selected.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return FutureBuilder<List<ListElement>>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load products: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No products found.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return Column(
          children: products.map((product) {
            return HomeProductCard(
              imageUrl: product.thumbnail,
              title: product.title,
              subtitle: product.description.isNotEmpty
                  ? product.description[LocaleUtils.getCurrentLanguageIndex()]
                  : '',
              price: product.price.toString(),
              foodId: product.id,
              onAdd: product.addOn.isNotEmpty
                  ? () => _showAddOnBottomSheet(product)
                  : () => _addToCartWithoutAddOns(product),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.foodDetail,
                  arguments: {
                    'categoryId': widget.categoryId!,
                    'foodId': product.id,
                    'foodsInCategory': products,
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
