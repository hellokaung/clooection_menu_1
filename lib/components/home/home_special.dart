import 'package:flutter/material.dart';
// Assuming these paths are correct
import '../../config/routes.dart';
import '../../database/data_io.dart';
import '../../models/raw_data.dart';

class SpecialLayout extends StatefulWidget {
  const SpecialLayout({Key? key}) : super(key: key);

  @override
  State<SpecialLayout> createState() => _SpecialLayoutState();
}

class _SpecialLayoutState extends State<SpecialLayout> {
  // NOTE: Assuming Special and ListElement models are defined in raw_data.dart
  Special? _special;
  List<ListElement> _specialItems = [];
  bool _isLoading = true;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _loadSpecialData();
  }

  Future<void> _loadSpecialData() async {
    try {
      final specialData = await DataIO.fetchSpecialWithStatus();

      if (specialData != null) {
        setState(() {
          _special = specialData['special'] as Special;
          _isActive = specialData['isActive'] as bool;
        });

        if (_isActive) {
          // NOTE: Added a null check for safety, though _isActive implies it's not null here
          if (_special != null) {
            final items = await DataIO.fetchListsByCategory(_special!.id);
            setState(() {
              _specialItems = items;
            });
          }
        }
      }
    } catch (e) {
      // In a real app, use a logging tool or show a snackbar
      print('Error loading special data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_special == null || !_isActive || _specialItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSpecialLayout();
  }

  Widget _buildLoading() {
    // Replaced Container height with Padding for better integration
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // --- REVISED _buildSpecialLayout FOR MODERN UI ---
  Widget _buildSpecialLayout() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      // 1. Group the entire section into a Card-like container
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Use surface for a clean background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08), // Subtle lift
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Modern Header with clear emphasis
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Icon with solid primary color background
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons
                            .local_fire_department_rounded, // Changed icon for "hot deal" vibe
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title with high contrast (no ShaderMask)
                    Text(
                      _special!.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                // 3. Compact, stylish badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme
                        .errorContainer, // Using an attention color (like red/orange) for "Limited Time"
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'LIMITED TIME', // Uppercase for urgency
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Horizontal List - slightly increased height
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _specialItems.length,
              itemBuilder: (context, index) {
                final item = _specialItems[index];
                return _buildModernSpecialItem(item, context);
              },
            ),
          ),

          // // 5. Optional Description/Call to Action
          // Padding(
          //   padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          //   child: Text(
          //     _special!.title,
          //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //       color: colorScheme.onSurfaceVariant,
          //     ),
          //     maxLines: 2,
          //     overflow: TextOverflow.ellipsis,
          //   ),
          // ),
        ],
      ),
    );
  }

  // --- REVISED _buildModernSpecialItem FOR MODERN UI ---
  Widget _buildModernSpecialItem(ListElement item, BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.foodDetail,
          arguments: {
            'categoryId': item.category,
            'foodId': item.id,
            'foodsInCategory': _specialItems,
          },
        );
      },
      child: Container(
        width: 170, // Slightly wider card
        margin: const EdgeInsets.only(right: 12), // Tighter spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with reduced, cleaner shadow
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 4,
                ), // Space below image before text
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Image
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                          item.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: colorScheme.surfaceVariant,
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 40,
                                ),
                              ),
                        ),
                      ),

                      // Price Tag (Styled as a bottom-right "sticker")
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme
                                .secondaryContainer, // Use a contrasting color
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            '฿${item.price}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content - Simplified layout
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // A subtitle can add detail without making the card cluttered
            // Padding(
            //   padding: const EdgeInsets.only(left: 4, right: 4),
            //   child: Text(
            //     'Discounted Item',
            //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //       color: colorScheme
            //           .primary, // Using primary color to draw attention
            //     ),
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
