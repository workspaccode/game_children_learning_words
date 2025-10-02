import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as material;

class LocalizationService {
  // Supported locales
  static const List<material.Locale> supportedLocales = [
    material.Locale('ar', 'SA'), // Arabic (Saudi Arabia)
    material.Locale('en', 'US'), // English (United States)
  ];

  // Default locale
  static const material.Locale defaultLocale = material.Locale('ar', 'SA');

  // Fallback locale
  static const material.Locale fallbackLocale = material.Locale('en', 'US');

  // Assets path for translations
  static const String translationsPath = 'assets/translations';

  // Initialize localization
  static Future<void> initialize() async {
    await EasyLocalization.ensureInitialized();
  }

  // Change language
  static Future<void> changeLanguage(
    material.BuildContext context,
    material.Locale locale,
  ) async {
    await context.setLocale(locale);
  }

  // Get current locale
  static material.Locale getCurrentLocale(material.BuildContext context) {
    return context.locale;
  }

  // Check if locale is supported
  static bool isLocaleSupported(material.Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  // Get locale from language code
  static material.Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return const material.Locale('ar', 'SA');
      case 'en':
        return const material.Locale('en', 'US');
      default:
        return defaultLocale;
    }
  }

  // Get language name
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }

  // Get language direction
  static material.TextDirection getTextDirection(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return material.TextDirection.rtl;
      case 'en':
        return material.TextDirection.ltr;
      default:
        return material.TextDirection.ltr;
    }
  }

  // Check if language is RTL
  static bool isRTL(String languageCode) {
    return languageCode == 'ar';
  }

  // Get opposite language code
  static String getOppositeLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'en';
      case 'en':
        return 'ar';
      default:
        return 'en';
    }
  }

  // Format number based on locale
  static String formatNumber(num number, String languageCode) {
    final locale = getLocaleFromLanguageCode(languageCode);
    final formatter = NumberFormat.decimalPattern(locale.toString());
    return formatter.format(number);
  }

  // Format currency based on locale
  static String formatCurrency(
    num amount,
    String languageCode, {
    String? currencySymbol,
  }) {
    final locale = getLocaleFromLanguageCode(languageCode);
    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: currencySymbol ?? (languageCode == 'ar' ? 'ر.س' : r'$'),
    );
    return formatter.format(amount);
  }

  // Format date based on locale
  static String formatDate(DateTime date, String languageCode) {
    final locale = getLocaleFromLanguageCode(languageCode);
    final formatter = DateFormat.yMMMd(locale.toString());
    return formatter.format(date);
  }

  // Format time based on locale
  static String formatTime(DateTime time, String languageCode) {
    final locale = getLocaleFromLanguageCode(languageCode);
    final formatter = DateFormat.jm(locale.toString());
    return formatter.format(time);
  }

  // Get localized text with fallback
  static String getLocalizedText(
    material.BuildContext context,
    String key, {
    String? fallback,
    Map<String, dynamic>? args,
  }) {
    try {
      return key.tr();
    } catch (e) {
      return fallback ?? key;
    }
  }

  // Pluralization helper
  static String getPlural(
    material.BuildContext context,
    String key,
    int count, {
    Map<String, dynamic>? args,
  }) {
    try {
      return key.plural(count);
    } catch (e) {
      return key;
    }
  }

  // Gender helper (for Arabic)
  static String getGender(
    material.BuildContext context,
    String key,
    String gender, {
    Map<String, dynamic>? args,
  }) {
    try {
      return '$key.$gender'.tr();
    } catch (e) {
      return key;
    }
  }

  // Validation messages
  static String getValidationMessage(
    material.BuildContext context,
    String field,
    String error,
  ) {
    final key = 'validation.$field.$error';
    return getLocalizedText(context, key, fallback: 'Validation error');
  }

  // Error messages
  static String getErrorMessage(
    material.BuildContext context,
    String errorCode,
  ) {
    final key = 'errors.$errorCode';
    return getLocalizedText(context, key, fallback: 'An error occurred');
  }
}
