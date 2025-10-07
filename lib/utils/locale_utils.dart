import 'dart:ui';

import '../providers/locale_provider.dart';

/// A utility class for locale-related operations.
class LocaleUtils {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('th'),
    Locale('my'),
    Locale('de'),
    Locale('zh'),
    Locale('ru'),
    Locale('he'),
    Locale('es'),
    Locale('ko'),
  ];

  /// Returns the index of the current locale in the supported locales list.
  ///
  /// The index corresponds to the position of the locale in [supportedLocales].
  /// Returns 0 (English) if the current locale is not found.
  static int getCurrentLanguageIndex() {
    final currentLocale = LocaleProvider.getCurrentLocale() ?? Locale('en');
    final index = supportedLocales.indexWhere(
      (locale) => locale == currentLocale,
    );
    return index >= 0 ? index : 0; // Fallback to 0 (English) if not found
  }
}
