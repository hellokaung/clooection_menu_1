import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:collection_menu_1/providers/home_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/raw_data.dart';
import '../global/fullscreen_image_method.dart';

class HomeCarousel extends StatelessWidget {
  const HomeCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (homeProvider.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${homeProvider.error}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => homeProvider.retry(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final slides = homeProvider.availableSlides;
        if (slides.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Center(child: Text('No slides available')),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 2 / 1, // Set 16:9 aspect ratio
                child: CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 2 / 1, // Ensure carousel respects 16:9
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: slides.length > 1,
                    autoPlay: slides.length > 1,
                    autoPlayInterval: homeProvider.autoPlayDuration,
                    onPageChanged: (index, reason) {
                      homeProvider.setCurrentSlideIndex(index);
                    },
                  ),
                  items: slides
                      .asMap()
                      .entries
                      .map(
                        (entry) =>
                            _CarouselCard(slide: entry.value, index: entry.key),
                      )
                      .toList(),
                ),
              ),
              if (slides.length > 1) ...[
                const SizedBox(height: 8),
                SmoothPageIndicator(
                  controller: PageController(
                    initialPage: homeProvider.currentSlideIndex,
                  ),
                  count: slides.length,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Theme.of(context).primaryColor,
                    dotColor: Colors.grey,
                    spacing: 4,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final Slide slide;
  final int index;

  const _CarouselCard({required this.slide, required this.index});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  // Assuming you have these imports:
  // import 'package:flutter/material.dart';
  // import 'package:cached_network_image/cached_network_image.dart';
  // import 'package:shimmer/shimmer.dart';

  void _showSlideDetails(BuildContext context) {
    // Constants for better maintainability
    const double borderRadius = 24.0;
    const double padding = 20.0;

    // Assuming 'slide' is an object available in the scope with 'title', 'desc', 'thumbnail', and 'link' properties.

    showModalBottomSheet(
      context: context,
      // Use true for isScrollControlled to allow the sheet to take more than half the screen,
      // which is often good for content-heavy sheets.
      isScrollControlled: true,
      // Elevate the bottom sheet slightly more
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      builder: (context) {
        // Get the height of the screen
        final screenHeight = MediaQuery.of(context).size.height;
        // Set a max height (e.g., 85% of screen height) for large content
        final maxHeight = screenHeight * 0.85;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SafeArea(
            // Use Padding on the outside for a clean visual separation at the bottom
            // No need for a separate viewInsets.bottom padding if we use the Scaffold/BottomSheet default
            // unless you have a persistent bottom navigation bar.
            child: Padding(
              // We still need to handle the keyboard, but `viewInsets.bottom` should be applied
              // to the *inner* scrollable content area if we want the sheet to resize.
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Keep the sheet height minimal initially
                children: [
                  // --- Drag Handle for better visual cue ---
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  // --- Scrollable Content Area ---
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: padding,
                          vertical: 8.0,
                        ), // Adjust vertical padding for spacing around the drag handle
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Image/Thumbnail Section (Enhanced)
                            GestureDetector(
                              onTap: () =>
                                  showFullScreenImage(slide.thumbnail, context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ), // Slightly larger radius for the image
                                child: slide.thumbnail.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: slide.thumbnail,
                                        height:
                                            200, // Slightly taller image for visual impact
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        // Good UX: Ensure aspect ratio is handled even during loading
                                        placeholder: (context, url) => AspectRatio(
                                          aspectRatio:
                                              16 / 9, // Example aspect ratio
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              color: Colors
                                                  .white, // Shimmer color base
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      )
                                    : Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ), // Increased vertical spacing
                            // 2. Title Section (Enhanced)
                            Text(
                              slide.title,
                              style: const TextStyle(
                                fontSize: 24, // Larger, more impactful title
                                fontWeight:
                                    FontWeight.w800, // Bolder font weight
                                color: Colors.black87, // Stronger text color
                                height:
                                    1.2, // Improved line height for readability
                              ),
                            ),
                            const SizedBox(height: 12), // Spacing below title
                            // 3. Description Section (Enhanced)
                            Text(
                              slide.desc,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors
                                    .grey[700], // Softer color for body text
                                height:
                                    1.5, // Excellent line height for body text readability
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ), // Increased vertical spacing
                            // 4. Action Button (Enhanced)
                            if (slide.link.isNotEmpty)
                              SizedBox(
                                width: double
                                    .infinity, // Full width button for better tap target
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    // Consider using a primary color for the button
                                    // primary: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _launchUrl(context, slide.link),
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Go to Resource',
                                  ), // More descriptive text
                                ),
                              ),
                            const SizedBox(
                              height: 24,
                            ), // Padding at the very bottom
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: slide.directGo && slide.link.isNotEmpty
          ? () => _launchUrl(context, slide.link)
          : () => _showSlideDetails(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            slide.thumbnail.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: slide.thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.grey[300]),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
            if (slide.showText)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.black.withOpacity(0.45),
                ),
              ),
            if (slide.showText)
              Positioned(
                left: 24,
                bottom: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slide.desc,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
