import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/cart_page.dart';
import '../pages/setting_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    SearchPage(),
    CartPage(),
    SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarBg = isDark
        ? colorScheme.secondaryContainer
        : colorScheme.primaryContainer;
    final iconColor = colorScheme.primary;
    final inactiveIconColor = colorScheme.onSurface.withOpacity(0.5);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: CurvedNavigationBar(
          index: _selectedIndex,
          backgroundColor: Colors.transparent,
          color: navBarBg,
          buttonBackgroundColor: iconColor,
          animationDuration: const Duration(milliseconds: 300),
          items: [
            Icon(
              Icons.home,
              color: _selectedIndex == 0 ? Colors.white : inactiveIconColor,
            ),
            Icon(
              Icons.search,
              color: _selectedIndex == 1 ? Colors.white : inactiveIconColor,
            ),
            Icon(
              Icons.shopping_cart,
              color: _selectedIndex == 2 ? Colors.white : inactiveIconColor,
            ),
            Icon(
              Icons.settings,
              color: _selectedIndex == 3 ? Colors.white : inactiveIconColor,
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          letIndexChange: (index) => true,
          height: 60,
        ),
      ),
    );
  }
}
