import 'package:flutter/material.dart';
import 'package:collection_menu_1/models/raw_data.dart';

class HomeCategoryBar extends StatefulWidget {
  final int typeIndex; // 0 = Food, 1 = Drink
  final int selectedIndex;
  final ValueChanged<int> onCategoryChanged;
  final List<Category> categories; // <-- FIXED: Added <Category> type

  const HomeCategoryBar({
    super.key,
    required this.typeIndex,
    required this.selectedIndex,
    required this.onCategoryChanged,
    required this.categories,
  });

  @override
  _HomeCategoryBarState createState() => _HomeCategoryBarState();
}

class _HomeCategoryBarState extends State<HomeCategoryBar> {
  // Flag to prevent the "Closed" dialog from showing on every single rebuild
  bool _closedDialogShown = false;

  @override
  void initState() {
    super.initState();
    // Run initial check if categories are already loaded at startup
    _autoSelectFirstAvailable(widget.categories, widget.selectedIndex);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --- New: Auto-selection logic runs when parent properties change (e.g., tab switch) ---
  @override
  void didUpdateWidget(covariant HomeCategoryBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-selection should ONLY run when the list of categories changes (e.g., switching from Food to Drink tab).
    // If the list is the same, we assume any index change was due to a user tap and we respect their selection.
    if (widget.categories != oldWidget.categories) {
      _autoSelectFirstAvailable(widget.categories, widget.selectedIndex);
    }
  }

  // Helper method to perform the auto-selection logic
  void _autoSelectFirstAvailable(List<Category> categories, int selectedIndex) {
    if (categories.isEmpty || selectedIndex >= categories.length) return;

    final currentSelectedAvailable = _isCategoryAvailable(
      categories[selectedIndex].openIn,
    );

    // Auto-select ONLY if the currently provided index is unavailable.
    if (!currentSelectedAvailable) {
      final firstAvailableIndex = categories.indexWhere(
        (cat) => _isCategoryAvailable(cat.openIn),
      );

      // If an available category is found AND it's not the one currently selected, switch to it.
      if (firstAvailableIndex != -1 && firstAvailableIndex != selectedIndex) {
        // We call the callback outside of the update cycle to safely update the parent provider's state
        Future.microtask(() {
          widget.onCategoryChanged(firstAvailableIndex);
        });
      }
    }
  }

  // --- Availability Logic (Kept and slightly improved for overnight schedules) ---
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

      // Handle overnight schedules (e.g., 22:00 - 06:00)
      if (endMinutes < startMinutes) {
        if (nowMinutes >= startMinutes || nowMinutes <= endMinutes) {
          return true;
        }
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.categories.isEmpty) {
      return const SizedBox(height: 56);
    }

    // Accessing elements without redundant 'as Category' cast
    final selectedCat = widget.categories[widget.selectedIndex];
    final selectedAvailable = _isCategoryAvailable(selectedCat.openIn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 60,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: widget.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              // Accessing elements without redundant 'as Category' cast
              final cat = widget.categories[i];
              final available = _isCategoryAvailable(cat.openIn);
              final isSelected = widget.selectedIndex == i;

              // --- M3 Color Logic for Chip Status ---

              // Background Color: Uses M3 dedicated colors for status and hierarchy.
              final backgroundColor = isSelected
                  ? available
                        ? theme
                              .colorScheme
                              .primary // Selected & Available
                        : theme
                              .colorScheme
                              .errorContainer // Selected & Unavailable
                  : available
                  ? theme
                        .colorScheme
                        .surfaceContainerHigh // Deselected & Available (Neutral)
                  : theme
                        .colorScheme
                        .errorContainer; // Deselected & Unavailable (Warning)

              // Text Color: High contrast relative to background.
              final textColor = isSelected
                  ? available
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onErrorContainer
                  : available
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onErrorContainer;

              // Border Color: Thicker border for selected state, explicit error border for unavailable state.
              final borderColor = isSelected
                  ? theme.colorScheme.primary
                  : available
                  ? theme.colorScheme.outlineVariant
                  : theme.colorScheme.error;

              return GestureDetector(
                // IMPORTANT: onTap is always active now to allow the user to select closed categories.
                onTap: () {
                  widget.onCategoryChanged(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(
                      28,
                    ), // Modern M3 pill shape
                    border: Border.all(
                      color: borderColor,
                      width: isSelected
                          ? 2
                          : 1.2, // Thicker border on selection
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(
                                0.15,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cat.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (!available)
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Icon(
                            // Icon indicating time/schedule restriction
                            Icons.access_time_filled_rounded,
                            color: isSelected
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.error,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // --- Enhanced Unavailability Warning Box for Selected Category ---
        // This warning still shows if the single selected category is unavailable
        if (!selectedAvailable)
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: 4,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              // Uses errorContainer for a high-visibility, yet soft warning
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_off_rounded,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${selectedCat.name} is currently unavailable. It is available from ${selectedCat.openIn}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
