import 'package:flutter/material.dart';
import '../screen/main_screen.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/cart_page.dart';
import '../pages/setting_page.dart';
import '../pages/food_detail_page.dart';
import '../models/raw_data.dart';

class AppRoutes {
  static const String main = '/';
  static const String home = '/home';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String setting = '/setting';
  static const String foodDetail = '/food-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case search:
        return MaterialPageRoute(
          builder: (_) => SearchPage(),
          settings: settings,
        );
      case cart:
        return MaterialPageRoute(
          builder: (_) => CartPage(),
          settings: settings,
        );
      case setting:
        return MaterialPageRoute(
          builder: (_) => SettingPage(),
          settings: settings,
        );
      case foodDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('categoryId') ||
            !args.containsKey('foodId') ||
            !args.containsKey('foodsInCategory')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid navigation arguments')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => FoodDetailPage(
            categoryId: args['categoryId'] as String,
            foodId: args['foodId'] as String,
            foodsInCategory: args['foodsInCategory'] as List<ListElement>,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
