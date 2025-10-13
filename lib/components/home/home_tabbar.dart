import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const HomeTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabs = [
      {'label': "home_foods".tr(), 'icon': Icons.restaurant_menu},
      {'label': "home_drinks".tr(), 'icon': Icons.local_drink},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;

          return Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(32),
            color: theme.colorScheme.surface,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 🟦 Smooth sliding background
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  left: selectedIndex == 1
                      ? tabWidth * selectedIndex - 4
                      : tabWidth * selectedIndex + 4,
                  width: tabWidth,
                  top: 4,
                  bottom: 4,

                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🧭 Foreground content
                Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedIndex == index;

                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTabChanged(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                scale: isSelected ? 1.1 : 1.0,
                                child: Icon(
                                  tabs[index]['icon'] as IconData,
                                  size: 22,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                                child: Text(tabs[index]['label'] as String),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
