import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TranslationService {
  // Get current locale
  static String getCurrentLanguage() {
    return 'ar'; // Default to Arabic
  }

  // Set language
  static Future<void> setLanguage(
    String languageCode,
    BuildContext context,
  ) async {
    if (languageCode == 'ar') {
      await context.setLocale(const Locale('ar'));
    } else if (languageCode == 'en') {
      await context.setLocale(const Locale('en'));
    }
  }

  // Get translated text
  static String translate(String key, {Map<String, dynamic>? args}) {
    return key.tr();
  }

  // Get plural translation
  static String translatePlural(
    String key,
    int count, {
    Map<String, dynamic>? args,
  }) {
    return key.plural(count);
  }

  // Check if current language is RTL
  static bool isRTL() {
    return getCurrentLanguage() == 'ar';
  }

  // Get supported locales
  static List<Locale> getSupportedLocales() {
    return const [Locale('ar'), Locale('en')];
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

  // Toggle language between Arabic and English
  static Future<void> toggleLanguage(BuildContext context) async {
    final currentLang = getCurrentLanguage();
    if (currentLang == 'ar') {
      await setLanguage('en', context);
    } else {
      await setLanguage('ar', context);
    }
  }

  // Translate text (mock implementation)
  static Future<String> translateText(
    String text,
    String targetLanguage,
  ) async {
    // This is a mock implementation
    // In a real app, you would use a translation API like Google Translate
    return text; // Return original text for now
  }

  // Translate list of texts (mock implementation)
  static Future<List<String>> translateTextList(
    List<String> texts,
    String targetLanguage,
  ) async {
    // This is a mock implementation
    // In a real app, you would use a translation API
    return texts; // Return original texts for now
  }

  // Detect language (mock implementation)
  static Future<String> detectLanguage(String text) async {
    // This is a mock implementation
    // In a real app, you would use a language detection API
    // Simple heuristic: if text contains Arabic characters, return 'ar'
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (arabicRegex.hasMatch(text)) {
      return 'ar';
    }
    return 'en';
  }
}
