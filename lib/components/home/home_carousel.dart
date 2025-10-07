import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeCarousel extends StatelessWidget {
  const HomeCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          enlargeCenterPage: true,
          viewportFraction: 1.0,
          enableInfiniteScroll: false,
        ),
        items: [
          _CarouselCard(
            imageUrl:
                'https://images.pexels.com/photos/461382/pexels-photo-461382.jpeg',
            title: 'Special Offer',
            subtitle: 'Get 20% off on your first order!',
          ),
          _CarouselCard(
            imageUrl:
                'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg',
            title: 'Pizza Day',
            subtitle: 'Buy 1 Get 1 Free!',
          ),
        ],
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  const _CarouselCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.black.withOpacity(0.45),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
