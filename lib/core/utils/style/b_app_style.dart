import 'package:flutter/material.dart';
import 'c_app_color.dart';

class AppStyle {

  AppStyle({this.themeIndex = 0});
  final int themeIndex;

  ThemeData get currentTheme {
    if (themeIndex >= 0 && themeIndex < AppColor.availableColorSchemes.length) {
      return ThemeData(
        fontFamily: 'MyFont',
        useMaterial3: true,
      //  primarySwatch: getMaterialColor(),
        colorScheme: AppColor.availableColorSchemes[themeIndex],
      );
    } else {
      // Return a default theme or any fallback behavior if the index is out of range.
      return ThemeData(
        useMaterial3: true,
        colorScheme: AppColor.availableColorSchemes[0],
      );
    }
  }
}
