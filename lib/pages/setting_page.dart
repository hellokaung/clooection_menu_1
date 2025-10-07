import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Dynamic Colors based on theme
    final iconColor = colorScheme.primary;
    final tileColor = colorScheme.surfaceContainerHigh;
    final bgColor =
        colorScheme.background; // Use background for general page color
    // Determine AppBar foreground color (icons/text) based on brightness
    final appBarFgColor = colorScheme.onSurface;

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface, // AppBar background color
        elevation: 1, // Subtle elevation
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: appBarFgColor),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'settings'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: appBarFgColor),
        ),
        centerTitle: true,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          children: [
            // --- About Tile ---
            _settingTile(
              context: context,
              icon: FontAwesomeIcons.store,
              label: 'about'.tr(),
              iconColor: iconColor,
              tileColor: tileColor,
              onTap: () => debugPrint('Tapped About'),
            ),
            // --- Dark Mode Tile with Switch ---
            _settingTile(
              context: context,
              icon: FontAwesomeIcons.moon,
              label: 'darkMode'.tr(),
              iconColor: iconColor,
              tileColor: tileColor,
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (val) => themeProvider.setDarkMode(val),
                activeColor: colorScheme.primary, // Active switch color
                inactiveThumbColor:
                    colorScheme.onSurfaceVariant, // Better contrast
                inactiveTrackColor:
                    colorScheme.surfaceContainer, // Better contrast
              ),
            ),
            // --- Language Tile (Opens BottomSheet) ---
            _settingTile(
              context: context,
              icon: FontAwesomeIcons.language,
              label: 'language'.tr(),
              iconColor: iconColor,
              tileColor: tileColor,
              onTap: () => _showLanguageBottomSheet(context, localeProvider),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for setting tiles
  Widget _settingTile({
    required BuildContext context, // Added context to get current text color
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color tileColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface; // Text color
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16),
        // Optional: Add a subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: FaIcon(
          icon,
          color: iconColor,
          size: 24,
        ), // Slightly smaller icon
        title: Text(
          label,
          style: TextStyle(
            color: textColor, // Use dynamic text color
            fontSize: 16, // Slightly smaller font size
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textColor.withOpacity(0.6),
              size: 18,
            ), // Better icon and color
        onTap: onTap,
      ),
    );
  }

  // --- REPLACED: Language Dialog with BottomSheet ---
  void _showLanguageBottomSheet(
    BuildContext context,
    LocaleProvider localeProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaceColor = colorScheme.surfaceContainerHigh;
    final onSurfaceColor = colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows content to take more space
      backgroundColor: surfaceColor, // Themed background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // List of supported languages
        final List<Map<String, String>> languages = [
          {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
          {'code': 'th', 'name': 'Thai', 'flag': '🇹🇭'},
          {'code': 'my', 'name': 'Burmese', 'flag': '🇲🇲'},
          {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
          {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
          {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺'},
          {'code': 'he', 'name': 'Hebrew', 'flag': '🇮🇱'},
          {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
          {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷'},
        ];

        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Handle/Drag Indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: onSurfaceColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 12),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 24.0,
                ),
                child: Text(
                  'language'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                ),
              ),
              const Divider(), // Separator
              // Language List
              Flexible(
                // Use Flexible/Expanded if the list is very long
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: languages.map((lang) {
                      return _languageOption(
                        context,
                        localeProvider,
                        lang['code']!,
                        lang['name']!,
                        lang['flag']!,
                        onSurfaceColor, // Pass text color
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Optional: Add some bottom padding for the home indicator area
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  // Helper method for individual language option tile
  Widget _languageOption(
    BuildContext context,
    LocaleProvider localeProvider,
    String langCode,
    String langName,
    String flag,
    Color textColor, // Receive dynamic text color
  ) {
    final isSelected = localeProvider.locale.languageCode == langCode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListTile(
      tileColor: isSelected
          ? primaryColor.withOpacity(0.1)
          : null, // Subtle highlight
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(langName, style: TextStyle(color: textColor)),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: primaryColor,
            ) // A more modern check icon
          : null,
      onTap: () {
        // Set the new locale
        localeProvider.setLocale(Locale(langCode), context);
        // Close the bottom sheet
        Navigator.pop(context);
      },
    );
  }
}
