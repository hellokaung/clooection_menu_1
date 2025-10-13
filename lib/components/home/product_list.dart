import 'package:collection_menu_1/providers/home_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../database/data_io.dart';
import '../../models/cart_item.dart';
import '../../models/raw_data.dart';
import 'addon_sheet.dart';
import 'waterfall_product_card.dart';

class ProductListSliver extends StatefulWidget {
  final ScrollController? scrollController;

  const ProductListSliver({super.key, this.scrollController});

  @override
  State<ProductListSliver> createState() => _ProductListSliverState();
}

class _ProductListSliverState extends State<ProductListSliver> {
  @override
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ListElement> products = context
        .watch<HomeProvider>()
        .foodsInSelectedCategory;
    return products.isEmpty
        ? SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'home_empty_category'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'home_empty_category_note'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 800),
                      child: FilledButton.tonal(
                        onPressed: () {
                          // Refresh or navigate action
                          context.read<HomeProvider>().retry();
                        },
                        child: Text('home_refresh_category'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            sliver: SliverWaterfallFlow(
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return WaterfallProductCard(
                  product: product,
                  products: products,
                  onAdd: () async {
                    if (product.addOn.isNotEmpty) {
                      await _showAddOnSheet(context, product);
                    } else {
                      await _addToCart(context, product, []);
                    }
                  },
                );
              }, childCount: products.length),
            ),
          );
  }

  Future<void> _addToCart(
    BuildContext context,
    ListElement product,
    List<AddOn> addOns,
  ) async {
    final int total = product.price + addOns.fold(0, (p, e) => p + e.price);
    await DataIO.addToCart(
      CartItem(
        id: product.id,
        thumbnail: product.thumbnail,
        title: product.title,
        addOns: addOns.map((e) => {'name': e.name, 'price': e.price}).toList(),
        note: '',
        totalPrice: total,
        times: 1,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${"home_added_to_cart".tr()} ${product.title}= ฿${total.toStringAsFixed(2)}',
        ),
      ),
    );
  }

  Future<void> _showAddOnSheet(
    BuildContext context,
    ListElement product,
  ) async {
    final addOns = await DataIO.fetchAddOns(
      product.addOn.isNotEmpty ? product.addOn : null,
    );
    if (!context.mounted) return;
    final selected = await showModalBottomSheet<List<AddOn>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AddOnSheet(product: product, availableAddOns: addOns),
    );
    if (selected != null && selected.isNotEmpty) {
      await _addToCart(context, product, selected);
    }
  }
}
