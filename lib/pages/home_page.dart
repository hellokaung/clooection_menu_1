import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../components/home/home_appbar.dart';
import '../components/home/home_carousel.dart';
import '../components/home/home_tabbar.dart';
import '../components/home/home_categorybar.dart';
import '../components/home/loading_widget.dart';
import '../components/home/error_widget.dart' as myerrorwidget;
import '../components/home/restart_notice_dialog.dart';
import '../components/home/product_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: ListView(
            children: [
              const HomeAppBar(),
              const HomeCarousel(),
              HomeTabBar(
                selectedIndex: provider.selectedTab,
                onTabChanged: provider.setTab,
              ),
              HomeCategoryBar(
                typeIndex: provider.selectedTab,
                selectedIndex: provider.selectedCategoryIndex,
                onCategoryChanged: provider.setCategory,
                categories: provider.currentCategories,
              ),
              const SizedBox(height: 8),
              ProductList(categoryId: provider.selectedCategoryId),
            ],
          ),
        );
      },
    );
  }
}
