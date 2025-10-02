import 'package:flutter/material.dart';

extension ThemeExtension on ThemeData {
  
    Color get primary => colorScheme.primary;
    Color get secondary => colorScheme.secondary;

}
extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorscheme => theme.colorScheme;
}