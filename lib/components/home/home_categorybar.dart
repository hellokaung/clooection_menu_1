import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection_menu_1/models/raw_data.dart';
import 'package:gif_view/gif_view.dart';
import 'package:provider/provider.dart';

import '../../providers/home_provider.dart';

class HomeCategoryBar extends StatefulWidget {
  final int typeIndex; // 0 = Food, 1 = Drink
  final int selectedIndex;
  final List<Category> categories;

  const HomeCategoryBar({
    super.key,
    required this.typeIndex,
    required this.selectedIndex,
    required this.categories,
  });

  @override
  State<HomeCategoryBar> createState() => _HomeCategoryBarState();
}

class _HomeCategoryBarState extends State<HomeCategoryBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _autoSelectFirstAvailable(widget.categories, widget.selectedIndex);
  }

  @override
  void didUpdateWidget(covariant HomeCategoryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categories != oldWidget.categories) {
      _autoSelectFirstAvailable(widget.categories, widget.selectedIndex);
    }

    // Scroll to selected item when it changes
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedIndex();
      });
    }
  }

  void _scrollToSelectedIndex() {
    final double itemWidth = 60; // Compact item width
    final double itemSpacing = 8;
    final double selectedItemWidth = 120; // Expanded selected item width

    double offset = 0;
    for (int i = 0; i < widget.selectedIndex; i++) {
      if (i == widget.selectedIndex - 1) {
        offset += itemWidth;
      } else {
        offset += itemWidth + itemSpacing;
      }
    }

    // Calculate the scroll position to center the selected item
    final double viewportWidth = MediaQuery.of(context).size.width - 24;
    final double selectedItemCenter = offset + (selectedItemWidth / 2);
    final double targetOffset = selectedItemCenter - (viewportWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _autoSelectFirstAvailable(List<Category> categories, int selectedIndex) {
    if (categories.isEmpty || selectedIndex >= categories.length) return;

    final currentSelectedAvailable = _isCategoryAvailable(
      categories[selectedIndex].openIn,
    );

    if (!currentSelectedAvailable) {
      final firstAvailableIndex = categories.indexWhere(
        (cat) => _isCategoryAvailable(cat.openIn),
      );
      if (firstAvailableIndex != -1 && firstAvailableIndex != selectedIndex) {
        Future.microtask(() {
          context.read<HomeProvider>().setCategory(firstAvailableIndex);
        });
      }
    }
  }

  bool _isCategoryAvailable(String openIn) {
    final now = TimeOfDay.now();
    try {
      final parts = openIn.split('-');
      if (parts.length != 2) return true;
      final start = _parseTime(parts[0]);
      final end = _parseTime(parts[1]);
      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      if (endMinutes < startMinutes) {
        if (nowMinutes >= startMinutes || nowMinutes <= endMinutes) return true;
      }
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } catch (_) {
      return true;
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.categories.isEmpty) {
      return const SizedBox(height: 90); // Increased height
    }

    final selectedCat = widget.categories[widget.selectedIndex];
    final selectedAvailable = _isCategoryAvailable(selectedCat.openIn);
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          // Bottom shadow only
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6), // Only vertical offset
          ),
          // Soft inner top glow to prevent shadow on top
          BoxShadow(
            color: theme.colorScheme.surface.withOpacity(0.8),
            blurRadius: 2,
            spreadRadius: -1,
            offset: const Offset(0, 1),
          ),
        ],
        // Optional border for more definition
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          SizedBox(
            height: 90 + 6 + 12 / 2,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = widget.categories[i];
                final available = _isCategoryAvailable(cat.openIn);
                final isSelected = widget.selectedIndex == i;

                return _VariableSizeCategoryItem(
                  category: cat,
                  isSelected: isSelected,
                  available: available,
                  theme: theme,
                  onTap: () {
                    context.read<HomeProvider>().setCategory(i);
                  },
                );
              },
            ),
          ),

          // Minimal unavailable indicator
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: child,
                ),
              );
            },
            child: !selectedAvailable
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      key: const ValueKey('unavailable_banner'),

                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: theme.colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${"home_available".tr()} ${selectedCat.openIn}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _VariableSizeCategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final bool available;
  final ThemeData theme;
  final VoidCallback onTap;

  const _VariableSizeCategoryItem({
    required this.category,
    required this.isSelected,
    required this.available,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: isSelected ? 120 : 60, // Expanded width for selected item
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            // Image container
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: isSelected ? 56 : 48, // Larger for selected
              height: isSelected ? 56 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (available
                            ? theme.colorScheme.outlineVariant
                            : theme.colorScheme.error),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image with fade animation
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: available ? 1.0 : 0.4,
                    child: ClipOval(
                      child:
                          category.iconId.toLowerCase().endsWith('.gif') &&
                              isSelected
                          ? GifView.network(
                              category.iconId,
                              fit: BoxFit.cover,
                              width: isSelected ? 52 : 44,
                              height: isSelected ? 52 : 44,
                              // placeholder: _buildCompactShimmer(),
                              frameRate: 30,
                            )
                          : CachedNetworkImage(
                              imageUrl: category.iconId,
                              fit: BoxFit.cover,
                              width: isSelected ? 52 : 44,
                              height: isSelected ? 52 : 44,
                              placeholder: (context, url) =>
                                  _buildCompactShimmer(),
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.surfaceVariant,
                                child: Icon(
                                  Icons.category,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: isSelected ? 24 : 20,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Unavailable indicator
                  if (!available)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: isSelected ? 14 : 12,
                        height: isSelected ? 14 : 12,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          color: theme.colorScheme.onError,
                          size: isSelected ? 9 : 8,
                        ),
                      ),
                    ),

                  // Selection indicator - dot animation
                  if (isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        width: isSelected ? 10 : 8,
                        height: isSelected ? 10 : 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6), // Increased spacing
            // Text container - Shows full text for selected item
            Container(
              constraints: BoxConstraints(
                maxWidth: isSelected ? 120 : 60,
                minHeight: isSelected
                    ? 32
                    : 16, // Ensure enough height for 2 lines
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                category.name,
                maxLines: isSelected ? 2 : 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: available
                      ? (isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface)
                      : theme.colorScheme.error,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: isSelected ? 12 : 11, // Slightly reduced font size
                  height: 1.1, // Reduced line height
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactShimmer() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }
}
