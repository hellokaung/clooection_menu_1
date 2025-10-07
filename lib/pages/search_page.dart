import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/data_io.dart';
import '../models/raw_data.dart';
import '../../config/routes.dart';
import '../../models/cart_item.dart';
import '../utils/locale_utils.dart';
import '../../providers/locale_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State {
  int selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Set selectedTypes = {};
  List filteredFoods = [];
  bool _showPlaceholder = false;
  final List types = [
    {'label': 'All', 'type': ""},
    {'label': 'Vegan', 'type': "vegan"},
    {'label': 'Vegetarian', 'type': "vegetarian"},
    {'label': 'Meat', 'type': "meat"},
    {'label': 'Seafood', 'type': "seafood"},
  ];
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFoods);
    _searchFocusNode.addListener(() {
      setState(() {});
    });
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future _loadInitialData() async {
    await DataIO.init();
    _filterFoods();
  }

  void _filterFoods() async {
    final foodType = types[selectedCategory]['type'];
    final searchQuery = _searchController.text.toLowerCase();
    if (foodType.isEmpty && searchQuery.isEmpty) {
      setState(() {
        filteredFoods = [];
        _showPlaceholder = true;
      });
    } else {
      final allFoods = await DataIO.searchLists(
        type: foodType.isEmpty ? null : foodType,
        query: searchQuery,
      );
      setState(() {
        filteredFoods = allFoods.where((food) {
          final matchesType =
              (foodType.isEmpty ||
                  food.types.toLowerCase() == foodType.toLowerCase()) ||
              selectedTypes.contains(food.types.toLowerCase());
          return matchesType;
        }).toList();
        _showPlaceholder = false;
      });
    }
  }

  Future _addToCartWithoutAddOns(ListElement product) async {
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

  Future _showAddOnBottomSheet(ListElement product) async {
    final List availableAddOns = await DataIO.fetchAddOns(
      product.addOn.isNotEmpty ? product.addOn : null,
    );
    final Set selectedAddOns = {};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Ensure totalPrice is calculated correctly, assuming addOn.price is int/num
              int totalPrice = product.price;
              for (String addOnName in selectedAddOns) {
                final addOn = availableAddOns.firstWhere(
                  (ao) => ao.name == addOnName,
                  orElse: () => AddOn(name: '', type: '', price: 0),
                );
                // Corrected price calculation: assuming AddOn.price is an int/num
                totalPrice += int.parse(addOn.price);
              }
              return DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                expand: false,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
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
                                'Add-ons for ${product.title}',
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
                          const SizedBox(height: 16),
                          if (availableAddOns.isEmpty)
                            const Text(
                              'No add-ons available.',
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount: availableAddOns.length,
                                itemBuilder: (context, index) {
                                  final addOn = availableAddOns[index];
                                  return CheckboxListTile(
                                    title: Text(addOn.name),
                                    subtitle: Text(
                                      '\$${addOn.price.toStringAsFixed(2)}',
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
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Display current total price in the bottom sheet
                              Text(
                                'Total: \$${totalPrice.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: ElevatedButton(
                                    onPressed: selectedAddOns.isEmpty
                                        ? null
                                        : () async {
                                            try {
                                              final cartItem = CartItem(
                                                id: product.id,
                                                thumbnail: product.thumbnail,
                                                title: product.title,
                                                addOns: selectedAddOns
                                                    .map((name) {
                                                      final addOn =
                                                          availableAddOns
                                                              .firstWhere(
                                                                (ao) =>
                                                                    ao.name ==
                                                                    name,
                                                                orElse: () =>
                                                                    AddOn(
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
                                                      (addOn) =>
                                                          addOn['name'] != '',
                                                    )
                                                    .toList(),
                                                note: '',
                                                totalPrice: totalPrice,
                                                times: 1,
                                              );
                                              await DataIO.addToCart(cartItem);
                                              Navigator.pop(context);
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
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Add to Cart'),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  void _focusSearchField() {
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    final isDark = myTheme.brightness == Brightness.dark;

    // Define colors for the clickable language switch button
    final buttonBgColor = myTheme.colorScheme.secondaryContainer;
    final buttonIconColor = myTheme.colorScheme.onSecondaryContainer;

    final Map typeColors = {
      'All': isDark ? Colors.yellow[300]! : Colors.yellow[700]!,
      'Vegan': isDark ? Colors.green[300]! : Colors.green[700]!,
      'Vegetarian': isDark ? Colors.lightGreen[300]! : Colors.lightGreen[700]!,
      'Meat': isDark ? Colors.red[300]! : Colors.red[700]!,
      'Seafood': isDark ? Colors.blue[300]! : Colors.blue[700]!,
    };
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // --- Search Bar and Language Switch (Sleeker Design) ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 4, // Added elevation for a floating effect
                        borderRadius: BorderRadius.circular(28),
                        color: myTheme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: TextStyle(
                              color: myTheme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search for dishes...',
                              hintStyle: TextStyle(
                                color: myTheme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: myTheme.colorScheme.onSurface,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: myTheme.colorScheme.onSurface,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterFoods();
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // --- Language Switcher Button ---
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, child) {
                        return Material(
                          elevation: 4, // Added elevation
                          borderRadius: BorderRadius.circular(14),
                          color: buttonBgColor,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              final currentIndex =
                                  LocaleUtils.getCurrentLanguageIndex();
                              final nextIndex =
                                  (currentIndex + 1) %
                                  LocaleUtils.supportedLocales.length;
                              final nextLocale =
                                  LocaleUtils.supportedLocales[nextIndex];
                              localeProvider.setLocale(nextLocale, context);
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.translate_rounded,
                                color: buttonIconColor,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // --- End Language Switcher ---
                  ],
                ),
              ),
            ),

            // --- Category Bar (Pinned) ---
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchCategoryHeaderDelegate(
                minHeight: 90,
                maxHeight: 90,
                child: SizedBox(
                  height: 90,
                  child: Container(
                    color: myTheme.colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: _buildCategoryBar(typeColors),
                    ),
                  ),
                ),
              ),
            ),

            // --- Enhanced Placeholder for Empty Search ---
            SliverToBoxAdapter(
              child: _showPlaceholder && selectedCategory == 0
                  ? Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 80,
                            color: myTheme.colorScheme.primary.withOpacity(0.6),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Find your perfect dish!',
                            style: myTheme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: myTheme.colorScheme.onBackground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start typing in the search bar or select a category to view items.',
                            style: TextStyle(
                              fontSize: 16,
                              color: myTheme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _focusSearchField,
                            icon: const Icon(Icons.keyboard_arrow_up),
                            label: const Text('Start Searching'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: myTheme.colorScheme.primary,
                              foregroundColor: myTheme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // --- Food Results List ---
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => i < filteredFoods.length
                    ? _buildFoodCard(filteredFoods[i])
                    : const SizedBox.shrink(),
                childCount: filteredFoods.length,
              ),
            ),

            // Added padding at the bottom of the list for better visual space
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar(Map typeColors) {
    // Styling refined to match Material 3 principles
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(types.length, (i) {
          final cat = types[i];
          final bool selected = i == selectedCategory;
          final color = typeColors[cat['label']]!;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat['label'],
                style: TextStyle(
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              selected: selected,
              onSelected: (bool value) {
                if (value) {
                  setState(() {
                    selectedCategory = i;
                    _filterFoods();
                  });
                }
              },
              selectedColor: color,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              side: BorderSide(
                color: selected
                    ? color
                    : Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFoodCard(ListElement food) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        // Using Card for standard elevation/shadow
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.foodDetail,
              arguments: {
                'categoryId': types[selectedCategory]['type'],
                'foodId': food.id,
                'foodsInCategory': filteredFoods,
              },
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Larger Image Area - Removed Hero widget.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        food.thumbnail,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.fastfood,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food.description.isNotEmpty
                                ? food.description[LocaleUtils.getCurrentLanguageIndex()]
                                : 'No description available in this language.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          // Price is now below description
                          Text(
                            '\$${food.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50), // Space for the Add Button
                  ],
                ),
              ),
              // Floating Add Button
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton.small(
                  heroTag: 'add_button_${food.id}',
                  onPressed: food.addOn.isNotEmpty
                      ? () => _showAddOnBottomSheet(food)
                      : () => _addToCartWithoutAddOns(food),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 4,
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  _SearchCategoryHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: maxHeight, child: child);
  }

  @override
  bool shouldRebuild(covariant _SearchCategoryHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
