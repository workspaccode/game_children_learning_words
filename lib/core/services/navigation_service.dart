import 'package:flutter/material.dart';

class NavigationService {
  factory NavigationService() => _instance;
  NavigationService._internal();
  static final NavigationService _instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateToAndClear(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  void goBack([dynamic result]) {
    navigatorKey.currentState!.pop(result);
  }

  bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  void goBackUntil(String routeName) {
    navigatorKey.currentState!.popUntil(
      (route) => route.settings.name == routeName,
    );
  }
}
