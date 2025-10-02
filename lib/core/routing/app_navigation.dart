import 'package:flutter/material.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/user_management_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/user_type_selection_screen.dart';
import '../../features/games/pronunciation/pronunciation_game_screen.dart';
import '../../features/games/sentence_building/sentence_building_game_screen.dart';
import '../../features/games/spelling/spelling_game_screen.dart';
import '../../features/games/word_matching/word_matching_game_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/parent_dashboard/children_management_screen.dart';
import '../../features/parent_dashboard/parent_dashboard_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/teacher_dashboard/create_activity_screen.dart';
import '../../features/teacher_dashboard/teacher_dashboard_screen.dart';

class AppNavigation {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/user-type-selection':
        return MaterialPageRoute(
          builder: (_) => const UserTypeSelectionScreen(),
        );
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // Child Routes
      case '/games/pronunciation':
        return MaterialPageRoute(
          builder: (_) => const PronunciationGameScreen(),
        );
      case '/games/sentence-building':
        return MaterialPageRoute(
          builder: (_) => const SentenceBuildingGameScreen(),
        );
      case '/games/spelling':
        return MaterialPageRoute(builder: (_) => const SpellingGameScreen());
      case '/games/word-matching':
        return MaterialPageRoute(
          builder: (_) => const WordMatchingGameScreen(),
        );

      // Parent Routes
      case '/parent/dashboard':
        return MaterialPageRoute(builder: (_) => const ParentDashboardScreen());
      case '/parent/children':
        return MaterialPageRoute(
          builder: (_) => const ChildrenManagementScreen(),
        );

      // Teacher Routes
      case '/teacher/dashboard':
        return MaterialPageRoute(
          builder: (_) => const TeacherDashboardScreen(),
        );
      case '/teacher/activity/create':
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments! as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CreateActivityScreen(
              studentId: args['studentId'] as String,
              classroomId: args['classroomId'] as String,
            ),
          );
        }
        return _errorRoute();

      // Admin Routes
      case '/admin/dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/admin/users':
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());
      case '/admin/reports':
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
      case '/admin/settings':
        return MaterialPageRoute(builder: (_) => const AdminSettingsScreen());
      case '/admin/users/details':
        if (settings.arguments is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) =>
                const UserManagementScreen(), // Replace with UserDetailsScreen when created
            settings: settings,
          );
        }
        return _errorRoute();

      // Common Routes
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator?.pushNamed<T>(routeName, arguments: arguments) ??
        Future.value();
  }

  static Future<T?> pushReplacementNamed<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator?.pushReplacementNamed<T, dynamic>(
          routeName,
          arguments: arguments,
        ) ??
        Future.value();
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator?.pushNamedAndRemoveUntil<T>(
          routeName,
          (Route<dynamic> route) => false,
          arguments: arguments,
        ) ??
        Future.value();
  }

  static void pop<T>([T? result]) {
    navigator?.pop<T>(result);
  }

  static bool canPop() {
    return navigator?.canPop() ?? false;
  }

  static void popUntil(String routeName) {
    navigator?.popUntil((route) => route.settings.name == routeName);
  }
}
