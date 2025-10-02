import 'package:flutter/material.dart';

class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Get current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  // Navigation methods using GoRouter
  static void push(String route, {Object? extra}) {
    final context = currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed(route, arguments: extra);
    }
  }

  static void pushReplacement(String route, {Object? extra}) {
    final context = currentContext;
    if (context != null) {
      Navigator.of(context).pushReplacementNamed(route, arguments: extra);
    }
  }

  static void pushNamedAndRemoveUntil(String route, {Object? extra}) {
    final context = currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (Route<dynamic> r) => false,
        arguments: extra,
      );
    }
  }

  // static void pop([Object? result]) {
  //   final context = currentContext;
  //   if (context != null && context.canPop()) {
  //     context.pop(result);
  //   }
  // }

  // static void popUntil(String route) {
  //   final context = currentContext;
  //   if (context != null) {
  //     while (context.canPop() &&
  //         GoRouterState.of(context).uri.toString() != route) {
  //       context.pop();
  //     }
  //   }
  // }

  // Legacy methods for compatibility (deprecated)
  // @deprecated
  // static void pushNamed(String route, {Object? arguments}) {
  //   push(route, extra: arguments);
  // }

  // @deprecated
  // static void pushReplacementNamed(String route, {Object? arguments}) {
  //   pushReplacement(route, extra: arguments);
  // }

  // @deprecated
  // static void pushNamedAndRemoveUntil(String route, {Object? arguments}) {
  //   go(route, extra: arguments);
  // }

  // // Utility methods
  // static bool canPop() {
  //   final context = currentContext;
  //   return context?.canPop() ?? false;
  // }

  // static String getCurrentRoute() {
  //   final context = currentContext;
  //   if (context != null) {
  //     return GoRouterState.of(context).uri.toString();
  //   }
  //   return '/';
  // }

  // static Map<String, String> getCurrentParams() {
  //   final context = currentContext;
  //   if (context != null) {
  //     return GoRouterState.of(context).pathParameters;
  //   }
  //   return {};
  // }

  // static Map<String, String> getCurrentQuery() {
  //   final context = currentContext;
  //   if (context != null) {
  //     return GoRouterState.of(context).uri.queryParameters;
  //   }
  //   return {};
  // }

  // Dialog helpers
  static Future<T?> showCustomDialog<T>({
    required Widget dialog,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    final context = currentContext;
    if (context != null) {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        builder: (context) => dialog,
      );
    }
    return Future.value();
  }

  static Future<T?> showBottomSheet<T>({
    required Widget sheet,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final context = currentContext;
    if (context != null) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        builder: (context) => sheet,
      );
    }
    return Future.value();
  }

  // Snackbar helpers
  static void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  static void hideSnackBar() {
    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // Focus helpers
  static void unfocus() {
    final context = currentContext;
    if (context != null) {
      FocusScope.of(context).unfocus();
    }
  }

  static void requestFocus(FocusNode focusNode) {
    final context = currentContext;
    if (context != null) {
      FocusScope.of(context).requestFocus(focusNode);
    }
  }
}
