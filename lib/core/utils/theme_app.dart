// config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Primary Colors - مناسبة للأطفال والتعلم
  static const Color primaryColor = Color(0xFF2196F3); // أزرق مشرق وودود
  static const Color secondaryColor = Color(0xFF4CAF50); // أخضر للنمو والنجاح
  static const Color tertiaryColor = Color(0xFF9C27B0); // بنفسجي للإبداع

  // 🌈 Supporting Colors
  static const Color successColor = Color(0xFF4CAF50); // أخضر للنجاح
  static const Color warningColor = Color(0xFFFF9800); // برتقالي للتحذير
  static const Color errorColor = Color(0xFFF44336); // أحمر للأخطاء
  static const Color infoColor = Color(0xFF2196F3); // أزرق للمعلومات

  // 🌅 Light Theme Colors
  static const Color lightBackground = Color(
    0xFFF8FAFF,
  ); // خلفية فاتحة مع لمسة زرقاء
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Color(0xFF1A1C1E);
  static const Color lightOnPrimary = Colors.white;

  // 🌙 Dark Theme Colors
  static const Color darkPrimaryColor = Color(
    0xFF64B5F6,
  ); // أزرق فاتح للوضع المظلم
  static const Color darkSecondaryColor = Color(
    0xFF81C784,
  ); // أخضر فاتح للوضع المظلم
  static const Color darkBackground = Color(0xFF0D1117); // خلفية مظلمة ناعمة
  static const Color darkSurface = Color(0xFF161B22); // سطح مظلم
  static const Color darkOnSurface = Color(0xFFE6EDF3);
  static const Color darkOnPrimary = Color(0xFF003A6B);

  // � Typography
  static const String primaryFontFamily = 'Cairo'; // للعربية
  static const String secondaryFontFamily = 'Poppins'; // للإنجليزية

  // �📚 Text Themes - مُحسنة للقراءة والوضوح
  static TextTheme get _baseTextTheme => const TextTheme(
    // عناوين كبيرة
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.2,
      fontFamily: primaryFontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.3,
      fontFamily: primaryFontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      height: 1.3,
      fontFamily: primaryFontFamily,
    ),

    // عناوين متوسطة
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
      fontFamily: primaryFontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
      fontFamily: primaryFontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      fontFamily: primaryFontFamily,
    ),

    // عناوين صغيرة
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      fontFamily: primaryFontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
      fontFamily: primaryFontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      fontFamily: primaryFontFamily,
    ),

    // نصوص أساسية
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.6,
      fontFamily: primaryFontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.5,
      fontFamily: primaryFontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      height: 1.4,
      fontFamily: primaryFontFamily,
    ),

    // تسميات وأزرار
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      fontFamily: primaryFontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.3,
      fontFamily: primaryFontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.2,
      fontFamily: primaryFontFamily,
    ),
  );

  // 🌅 Light Theme - الوضع الفاتح
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // نظام الألوان المحسن
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: tertiaryColor,
      onTertiary: Colors.white,
      error: errorColor,
      onSurface: lightOnSurface,
      outline: Color(0xFFCAC4D0),
      outlineVariant: Color(0xFFE7E0EC),
    ),

    scaffoldBackgroundColor: lightBackground,

    // شريط التطبيق
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: lightBackground,
      foregroundColor: lightOnSurface,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
        fontFamily: primaryFontFamily,
      ),
    ),

    // البطاقات
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),

    // الأزرار المرفوعة
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: primaryFontFamily,
        ),
      ),
    ),

    // الأزرار المحددة
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primaryColor.withOpacity(0.8), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: primaryFontFamily,
        ),
      ),
    ),

    // أزرار النص
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: primaryFontFamily,
        ),
      ),
    ),

    // حقول الإدخال
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
    ),

    textTheme: _baseTextTheme.apply(
      bodyColor: lightOnSurface,
      displayColor: lightOnSurface,
    ),

    fontFamily: primaryFontFamily,
  );

  // 🌙 Dark Theme - الوضع المظلم
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // نظام الألوان المظلمة المحسن
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      onPrimary: darkOnPrimary,
      secondary: darkSecondaryColor,
      onSecondary: Color(0xFF003821),
      tertiary: Color(0xFFD0BCFF),
      onTertiary: Color(0xFF381E72),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: darkSurface,
      onSurface: darkOnSurface,
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),
    ),

    scaffoldBackgroundColor: darkBackground,

    // شريط التطبيق
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: darkBackground,
      foregroundColor: darkOnSurface,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
        fontFamily: primaryFontFamily,
      ),
    ),

    // البطاقات
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),

    // الأزرار المرفوعة
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shadowColor: darkPrimaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: primaryFontFamily,
        ),
      ),
    ),

    // الأزرار المحددة
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: darkPrimaryColor.withOpacity(0.8), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: primaryFontFamily,
        ),
      ),
    ),

    // أزرار النص
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: primaryFontFamily,
        ),
      ),
    ),

    // حقول الإدخال
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
      ),
    ),

    textTheme: _baseTextTheme.apply(
      bodyColor: darkOnSurface,
      displayColor: darkOnSurface,
    ),

    fontFamily: primaryFontFamily,
  );

  // 🎨 دوال مساعدة للحصول على الألوان حسب السياق
  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF81C784)
        : successColor;
  }

  static Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFB74D)
        : warningColor;
  }

  static Color getInfoColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimaryColor
        : infoColor;
  }

  // 🎭 دوال مساعدة للانميشن والتفاعل
  static Duration get quickAnimation => const Duration(milliseconds: 200);
  static Duration get mediumAnimation => const Duration(milliseconds: 300);
  static Duration get slowAnimation => const Duration(milliseconds: 500);

  static Curve get standardCurve => Curves.easeInOut;
  static Curve get accelerateCurve => Curves.easeIn;
  static Curve get decelerateCurve => Curves.easeOut;
}
