import 'package:flutter/material.dart';

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
    final tabs = ['Food', 'Drink'];
    final theme = Theme.of(context);

    // Using Material for a subtle elevated background, creating a segmented control effect.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 2, // Slight elevation for a "floating" feel
        borderRadius: BorderRadius.circular(32),
        // Use a neutral color for the base of the tab bar (M3 standard)
        color: theme.colorScheme.surfaceContainerHigh,
        child: Container(
          padding: const EdgeInsets.all(
            4,
          ), // Inner padding separates tabs from the container edge
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = selectedIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTabChanged(index),
                  // Apply border radius to the InkWell for better visual feedback
                  borderRadius: BorderRadius.circular(28),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 40,
                    decoration: BoxDecoration(
                      // Active tab uses primary color for high contrast
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[index],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        // Text color changes dynamically based on background
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
