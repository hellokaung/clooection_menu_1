import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart'; // REQUIRED: Import for Hive functionality

/// A provider to manage the app's locale and persist the user's preference.
class LocaleProvider with ChangeNotifier {
  // Box name and key for persistence.
  static const String _localeBoxName = 'settings';
  static const String _localeKey = 'languageCode';

  // Use a nullable Locale to represent the state before full initialization
  Locale? _currentLocale;

  LocaleProvider() {
    _loadPersistedLocale();
  }

  // Getter to access the current locale, defaults to English if not set
  Locale get locale => _currentLocale ?? const Locale('en');

  // Load the persisted locale from Hive
  void _loadPersistedLocale() async {
    // Open the box (assuming Hive.initFlutter() is called in main.dart)
    final settingsBox = await Hive.openBox(_localeBoxName);
    // Use the saved language code, defaulting to 'en'
    final savedCode = settingsBox.get(_localeKey, defaultValue: 'en');
    _currentLocale = Locale(savedCode);
    notifyListeners();
  }

  // Setter to change the locale and persist the change
  void setLocale(Locale newLocale, BuildContext context) async {
    // FIX: Access supportedLocales via the context
    if (!context.supportedLocales.contains(newLocale)) return;

    // 1. Update EasyLocalization context (which handles the UI language change)
    // This also persists the change internally using easy_localization's method,
    // but we use our own Hive storage for definitive app restart state control.
    await EasyLocalization.of(context)?.setLocale(newLocale);

    // 2. Update internal state and explicitly persist the preference via Hive
    _currentLocale = newLocale;

    // Persist the new language code using Hive
    final settingsBox = await Hive.openBox(_localeBoxName);
    await settingsBox.put(_localeKey, newLocale.languageCode);

    notifyListeners();
  }

  // Static key needed for navigator
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Helper method to get the current locale statically (used by LocaleUtils)
  static Locale? getCurrentLocale() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      return context.locale;
    }
    return null;
  }
}
