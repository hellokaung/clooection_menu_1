import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_provider.dart';
import '../../utils/locale_utils.dart'; // Ensure this utility file is available

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Retrieve dynamic colors from the current theme's ColorScheme
    final colorScheme = Theme.of(context).colorScheme;

    // Primary color for accents (like the 'for' text and the dining icon)
    final accentColor = colorScheme.primary;
    // Foreground color for text and general icons (ensures good contrast with app background)
    final foregroundColor = colorScheme.onSurface;

    // Colors for the interactive button
    final buttonBgColor = colorScheme.secondaryContainer;
    final buttonIconColor = colorScheme.onSecondaryContainer;

    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- App Title and Icon ---
          Row(
            children: [
              // Updated Icon: Using a rounded dining icon and the accent color
              Icon(Icons.local_dining_rounded, color: accentColor, size: 32),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: foregroundColor, // Use dynamic foreground color
                  ),
                  children: [
                    const TextSpan(text: 'Taste '),
                    // Accent word using the theme's primary color
                    TextSpan(
                      text: 'for ',
                      style: TextStyle(color: accentColor),
                    ),
                    const TextSpan(text: 'You'),
                  ],
                ),
              ),
            ],
          ),

          // --- Language Switcher Button (Now visually distinct) ---
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return Container(
                // Giving the icon a distinct background to signal interactivity
                decoration: BoxDecoration(
                  color: buttonBgColor,
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Rounded rectangular shape
                ),
                child: IconButton(
                  // Updated Icon: Using a rounded translate icon
                  icon: Icon(
                    Icons.translate_rounded,
                    color:
                        buttonIconColor, // Icon color contrasts well with the button background
                    size:
                        24, // Adjusted size to fit well within the container padding
                  ),
                  onPressed: () {
                    // Logic to cycle through supported languages
                    final currentIndex = LocaleUtils.getCurrentLanguageIndex();
                    final nextIndex =
                        (currentIndex + 1) %
                        LocaleUtils.supportedLocales.length;
                    final nextLocale = LocaleUtils.supportedLocales[nextIndex];
                    localeProvider.setLocale(nextLocale, context);
                  },
                  tooltip: 'Switch Language',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
