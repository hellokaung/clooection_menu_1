import 'dart:ui';

import 'package:collection_menu_1/utils/locale_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../components/global/fullscreen_image_method.dart';
import '../database/data_io.dart';
import '../models/raw_data.dart';
import '../models/cart_item.dart';
import 'cart_page.dart';

class FoodDetailPage extends StatefulWidget {
  final String categoryId;
  final String foodId;
  final List<ListElement> foodsInCategory;

  const FoodDetailPage({
    super.key,
    required this.categoryId,
    required this.foodId,
    required this.foodsInCategory,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage>
    with SingleTickerProviderStateMixin {
  late ListElement currentFood;
  late int initialPage;
  final Set<String> selectedAddOns = <String>{};
  bool isFavorite = false;
  late List<AddOn> allAddOns = [];
  late Future<List<AddOn>> _addOnsFuture;
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    initialPage = widget.foodsInCategory.indexWhere(
      (food) => food.id == widget.foodId,
    );
    if (initialPage == -1) initialPage = 0;
    currentFood = widget.foodsInCategory[initialPage];

    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.85,
    );

    _addOnsFuture = _loadAddOns();
    _checkFavoriteStatus();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await DataIO.checkFav(currentFood.id);
    setState(() {
      isFavorite = isFav;
    });
  }

  Future<List<AddOn>> _loadAddOns() async {
    final addOns = await DataIO.fetchAddOns(null);
    setState(() {
      allAddOns = addOns;
    });
    return addOns;
  }

  int get totalPrice {
    int price = currentFood.price;
    for (String addOnName in selectedAddOns) {
      final addOn = allAddOns.firstWhere(
        (ao) => ao.name == addOnName,
        orElse: () => AddOn(name: '', type: '', price: 0),
      );
      price += addOn.price;
    }
    return price;
  }

  void _onPageChanged(int index) {
    setState(() {
      currentFood = widget.foodsInCategory[index];
      selectedAddOns.clear();
      _noteController.clear();
    });
    _checkFavoriteStatus();
  }

  void _toggleAddOn(String addOnName) {
    setState(() {
      if (selectedAddOns.contains(addOnName)) {
        selectedAddOns.remove(addOnName);
      } else {
        selectedAddOns.add(addOnName);
      }
    });
  }

  void _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });
    if (isFavorite) {
      await DataIO.addFav(currentFood.id);
    } else {
      await DataIO.removeFav(currentFood.id);
    }
  }

  Future<void> _addToCart() async {
    final note = _noteController.text.trim();
    final addOnsList = selectedAddOns
        .map((addOnName) {
          final addOn = allAddOns.firstWhere(
            (ao) => ao.name == addOnName,
            orElse: () => AddOn(name: '', type: '', price: 0),
          );
          return {'name': addOn.name, 'price': addOn.price};
        })
        .where((addOn) => addOn['name'] != '')
        .toList();

    final cartItem = CartItem(
      id: currentFood.id,
      thumbnail: currentFood.thumbnail,
      title: currentFood.title,
      addOns: addOnsList,
      note: note,
      totalPrice: totalPrice,
      times: 1,
    );

    try {
      await DataIO.addToCart(cartItem);
      _animationController.forward();
      final message =
          '${"food_detail_added_to_cart".tr()} ${currentFood.title} - ฿${totalPrice.toStringAsFixed(2)}';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("food_detail_failed_to_add".tr())));
    }
  }

  Future<void> _launchGoogleImageSearch(String ingredient) async {
    try {
      final encodedIngredient = Uri.encodeQueryComponent(ingredient);
      final url = Uri.parse(
        'https://www.google.com/search?tbm=isch&q=$encodedIngredient',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } else {
        throw 'food_detail_no_broswer'.tr();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('food_detail_failed_to_open'.tr())),
      );
    }
  }

  Map<String, dynamic> _getFoodTypeDetails(
    String type,
    ThemeData theme, {
    bool isDark = false,
  }) {
    // Base colors
    const Color VEGAN_COLOR = Color(0xFF1B5E20);
    const Color VEGETARIAN_COLOR = Color(0xFF388E3C);
    const Color SEAFOOD_COLOR = Color(0xFF0277BD);
    const Color MEAT_COLOR = Color(0xFFD32F2F);
    const Color GLUTENFREE_COLOR = Color(0xFF6A1B9A);
    const Color ALCOHOL_COLOR = Color(0xFF8E24AA);
    const Color NONALCOHOL_COLOR = Color(0xFF00ACC1);
    const Color UNKNOWN_COLOR = Color(0xFF757575);

    switch (type.toLowerCase()) {
      case 'vegan':
        return {
          'label': 'food_vegan'.tr(),
          'icon': Icons.eco_rounded,
          'color': VEGAN_COLOR,
          'bgColor': VEGAN_COLOR.withOpacity(0.1),
        };

      case 'vegetarian':
        return {
          'label': 'food_vegetarian'.tr(),
          'icon': Icons.grass_rounded,
          'color': VEGETARIAN_COLOR,
          'bgColor': VEGETARIAN_COLOR.withOpacity(0.1),
        };

      case 'seafood':
        return {
          'label': 'food_seafood'.tr(),
          'icon': Icons.set_meal_rounded,
          'color': SEAFOOD_COLOR,
          'bgColor': SEAFOOD_COLOR.withOpacity(0.1),
        };

      case 'meat':
        return {
          'label': 'food_meat'.tr(),
          'icon': Icons.set_meal_sharp,
          'color': MEAT_COLOR,
          'bgColor': MEAT_COLOR.withOpacity(0.1),
        };

      case 'glutenfree': // handle typo gracefully
        return {
          'label': 'food_gluten_free'.tr(),
          'icon': Icons.no_food_rounded,
          'color': GLUTENFREE_COLOR,
          'bgColor': GLUTENFREE_COLOR.withOpacity(0.1),
        };

      case 'alcohol':
        return {
          'label': 'food_alcoholic'.tr(),
          'icon': Icons.local_bar_rounded,
          'color': ALCOHOL_COLOR,
          'bgColor': ALCOHOL_COLOR.withOpacity(0.1),
        };

      case 'nonalcohol':
        return {
          'label': 'food_non_alcoholic'.tr(),
          'icon': Icons.local_drink_rounded,
          'color': NONALCOHOL_COLOR,
          'bgColor': NONALCOHOL_COLOR.withOpacity(0.1),
        };

      default:
        return {
          'label': 'food_unknown'.tr(),
          'icon': Icons.help_outline_rounded,
          'color': UNKNOWN_COLOR,
          'bgColor': UNKNOWN_COLOR.withOpacity(0.1),
        };
    }
  }

  // FIXED: Proper scroll behavior method
  ScrollBehavior _buildScrollBehavior(BuildContext context) {
    return ScrollConfiguration.of(context).copyWith(
      scrollbars: true, // Keep scrollbars for web
      overscroll: true, // Enable overscroll for better UX
      dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      },
      physics: const BouncingScrollPhysics(), // Better feel for web
    );
  }

  Widget _buildFoodCarousel(ThemeData theme) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildWebFriendlyPageView(theme)),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.foodsInCategory.length,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                    activeDotColor: theme.colorScheme.primary,
                    dotColor: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ],
        ),

        if (kIsWeb && widget.foodsInCategory.length > 1) ...[
          Positioned(
            left: 16,
            top: 0,
            bottom: 60,
            child: Center(
              child: _buildNavigationArrow(
                theme,
                Icons.chevron_left_rounded,
                () => _goToPreviousPage(),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 60,
            child: Center(
              child: _buildNavigationArrow(
                theme,
                Icons.chevron_right_rounded,
                () => _goToNextPage(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationArrow(
    ThemeData theme,
    IconData icon,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
      ),
    );
  }

  void _goToPreviousPage() {
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage > 0) {
      _pageController.animateToPage(
        currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage < widget.foodsInCategory.length - 1) {
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildWebFriendlyPageView(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: constraints.maxHeight,
          // FIXED: Use ScrollConfiguration properly
          child: ScrollConfiguration(
            behavior: _buildScrollBehavior(context),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.foodsInCategory.length,
              onPageChanged: _onPageChanged,
              physics: const PageScrollPhysics(),
              padEnds: false,
              itemBuilder: (context, index) {
                final food = widget.foodsInCategory[index];
                return _buildFoodImageItem(food, theme, constraints.maxHeight);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodImageItem(
    ListElement food,
    ThemeData theme,
    double maxHeight,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showFullScreenImage(food.thumbnail, context),
          // FIXED: Improved drag handling for web
          onPanUpdate: (details) {
            if (details.delta.dx.abs() > 15) {
              // Increased sensitivity
              final currentPage = _pageController.page ?? 0;
              final newPage = (currentPage - details.delta.dx.sign)
                  .round()
                  .clamp(0, widget.foodsInCategory.length - 1);
              if (newPage != currentPage.round()) {
                _pageController.animateToPage(
                  newPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Image.network(
                  food.thumbnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: maxHeight,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: theme.colorScheme.surfaceContainerHigh,
                      highlightColor: theme.colorScheme.surfaceContainer,
                      child: Container(
                        width: double.infinity,
                        height: maxHeight,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.surfaceContainerHigh,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 100,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),

                // if (kIsWeb) ...[
                //   Positioned(
                //     left: 0,
                //     top: 0,
                //     bottom: 0,
                //     child: Container(
                //       width: 60,
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           begin: Alignment.centerLeft,
                //           end: Alignment.centerRight,
                //           colors: [
                //             theme.colorScheme.surface.withOpacity(0.7),
                //             Colors.transparent,
                //           ],
                //         ),
                //       ),
                //       child: Center(
                //         child: Icon(
                //           Icons.chevron_left_rounded,
                //           color: theme.colorScheme.onSurface.withOpacity(0.8),
                //           size: 32,
                //         ),
                //       ),
                //     ),
                //   ),
                //   Positioned(
                //     right: 0,
                //     top: 0,
                //     bottom: 0,
                //     child: Container(
                //       width: 60,
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           begin: Alignment.centerRight,
                //           end: Alignment.centerLeft,
                //           colors: [
                //             theme.colorScheme.surface.withOpacity(0.7),
                //             Colors.transparent,
                //           ],
                //         ),
                //       ),
                //       child: Center(
                //         child: Icon(
                //           Icons.chevron_right_rounded,
                //           color: theme.colorScheme.onSurface.withOpacity(0.8),
                //           size: 32,
                //         ),
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(ThemeData theme) {
    final textTheme = theme.textTheme;
    final photos = currentFood.photos;

    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'food_detail_additional_views'.tr(),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            // FIXED: Add web-friendly scroll behavior to gallery too
            child: ScrollConfiguration(
              behavior: _buildScrollBehavior(context),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photoUrl = photos[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () => showFullScreenImage(photoUrl, context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          photoUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: theme.colorScheme.surfaceContainerHigh,
                              highlightColor:
                                  theme.colorScheme.surfaceContainer,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 100,
                                height: 100,
                                color: theme.colorScheme.surfaceContainerHigh,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 30,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnList(List<AddOn> relevantAddOns, ThemeData theme) {
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'food_detail_custom_add_on'.tr(),
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: relevantAddOns.length,
          itemBuilder: (context, index) {
            final addOn = relevantAddOns[index];
            final isSelected = selectedAddOns.contains(addOn.name);

            return InkWell(
              onTap: () => _toggleAddOn(addOn.name),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        addOn.name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+฿${addOn.price}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final foodTypeDetails = _getFoodTypeDetails(currentFood.types, theme);
    DataIO.getCartItems();
    String desc;
    try {
      desc = currentFood.description[LocaleUtils.getCurrentLanguageIndex()];
    } catch (e) {
      desc = currentFood.description[0];
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // FIXED: Apply scroll behavior to main scroll view too
      body: ScrollConfiguration(
        behavior: _buildScrollBehavior(context),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350.0,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                background: _buildFoodCarousel(theme),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              actions: [
                ValueListenableBuilder(
                  valueListenable: DataIO.cartBox.listenable(),
                  builder: (context, Box<Map> box, _) {
                    final cartItems = DataIO.getCartItems();
                    final cartCount = cartItems.fold(
                      0,
                      (sum, item) => sum + item.times,
                    );
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return ScaleTransition(
                          scale: _animation,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.surface
                                    .withOpacity(0.8),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.shopping_cart_rounded,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CartPage(),
                                    ),
                                  ),
                                ),
                              ),
                              if (cartCount > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      cartCount.toString(),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onError,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                    child: IconButton(
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                  child: SingleChildScrollView(
                    key: ValueKey(currentFood.id),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                currentFood.title,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: foodTypeDetails['bgColor'] as Color,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (foodTypeDetails['color'] as Color)
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    foodTypeDetails['icon'] as IconData,
                                    size: 18,
                                    color: foodTypeDetails['color'] as Color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    foodTypeDetails['label'] as String,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: foodTypeDetails['color'] as Color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '฿${currentFood.price.toStringAsFixed(2)}',
                          style: textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentFood.photos.isNotEmpty)
                          _buildPhotoGallery(theme),

                        const SizedBox(height: 16),
                        Text(
                          desc,
                          style: textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'food_details_ingredients'.tr(),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: currentFood.ingredients
                              .map(
                                (ingredient) => ActionChip(
                                  label: Text(ingredient),
                                  avatar: const Icon(
                                    Icons.search_rounded,
                                    size: 18,
                                  ),
                                  labelStyle: textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                  ),
                                  backgroundColor:
                                      theme.colorScheme.tertiaryContainer,
                                  onPressed: () =>
                                      _launchGoogleImageSearch(ingredient),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),

                        FutureBuilder<List<AddOn>>(
                          future: _addOnsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final addOns = snapshot.data ?? [];
                            final relevantAddOns = addOns
                                .where(
                                  (addOn) =>
                                      currentFood.addOn.contains(addOn.type),
                                )
                                .toList();

                            if (relevantAddOns.isNotEmpty) {
                              return _buildAddOnList(relevantAddOns, theme);
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'food_special_instructions'.tr(),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: 'food_detail_special_instructions_note'
                                .tr(),
                            hintStyle: textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.6),
                            ),
                            alignLabelWithHint: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHigh,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              '${"food_add_to_cart".tr()} - ฿${totalPrice.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
