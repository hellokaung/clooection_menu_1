import 'package:flutter/material.dart';

// Assuming this utility exists for the image preview feature
import '../global/fullscreen_image_method.dart';

class HomeProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price; // Should be a string representation of a price
  final VoidCallback onAdd;
  final VoidCallback onTap;
  final String foodId;

  const HomeProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onAdd,
    required this.onTap,
    required this.foodId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using Card for M3 styling and elevation, consistent with SearchPage cards.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation:
            4, // Slightly higher elevation for prominence on the home page
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Image Area (Hero Animation Removed) ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      // Removed Hero widget. The food image will appear instantly
                      // without a transition animation when navigating to the detail screen.
                      child: imageUrl.isNotEmpty
                          ? GestureDetector(
                              // onTap logic remains to show the full-screen image preview
                              onTap: () => showFullScreenImage(
                                imageUrl,
                                foodId, // foodId still passed for context/unique ID
                                context,
                              ),
                              child: Image.network(
                                imageUrl,
                                width: 88, // Slightly larger image
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 88,
                                      height: 88,
                                      color: theme.colorScheme.surfaceVariant,
                                      child: Icon(
                                        Icons.fastfood,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                              ),
                            )
                          : Container(
                              width: 88,
                              height: 88,
                              color: theme.colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.image_not_supported,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),

                    // --- Text Content ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // The 'subtitle' (description) now fully wraps
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                            maxLines: null, // Allow unlimited lines
                            overflow: TextOverflow
                                .visible, // Ensure all text is visible
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${price}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20), // Space for the floating button
                  ],
                ),
              ),

              // --- Floating Add Button (Consistent with SearchPage) ---
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton.small(
                  heroTag: 'add_button_$foodId', // Unique tag for the FAB
                  onPressed: onAdd,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 6, // Slightly more prominent elevation
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
