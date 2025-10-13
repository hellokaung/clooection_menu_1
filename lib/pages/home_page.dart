import 'package:collection_menu_1/components/home/home_special.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../components/home/home_appbar.dart';
import '../components/home/home_carousel.dart';
import '../components/home/home_tabbar.dart';
import '../components/home/home_categorybar.dart';
import '../components/home/loading_widget.dart';
import '../components/home/error_widget.dart' as myerrorwidget;
import '../components/home/product_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void dispose() {
    // Dispose all scroll controllers
    _scrollControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  ScrollController _getScrollController(String categoryId) {
    if (!_scrollControllers.containsKey(categoryId)) {
      _scrollControllers[categoryId] = ScrollController();
    }
    return _scrollControllers[categoryId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Scaffold(body: LoadingWidget());
        }
        if (provider.error != null) {
          return Scaffold(
            body: myerrorwidget.ErrorWidget(message: provider.error!),
          );
        }

        final currentCategoryId = provider.selectedCategoryId;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            // Use the scroll controller for the current category
            controller: currentCategoryId != null
                ? _getScrollController(currentCategoryId)
                : null,
            slivers: [
              SliverToBoxAdapter(child: const HomeAppBar()),
              SliverToBoxAdapter(child: const HomeCarousel()),
              SliverToBoxAdapter(child: SpecialLayout()),

              SliverToBoxAdapter(
                child: HomeTabBar(
                  selectedIndex: provider.selectedTab,
                  onTabChanged: provider.setTab,
                ),
              ),
              SliverStickyHeader(
                header: HomeCategoryBar(
                  typeIndex: provider.selectedTab,
                  selectedIndex: provider.selectedCategoryIndex,
                  categories: provider.currentCategories,
                ),
                sliver: ProductListSliver(),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ],
          ),
        );
      },
    );
  }
}
