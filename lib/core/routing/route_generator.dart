import 'package:flutter/material.dart';
import 'package:readingquest_bilingual_learning/core/routing/app_routes.dart';

// Admin Features
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/user_management_screen.dart';
import '../../features/auth/child_completion_screen.dart';
import '../../features/auth/google_user_type_screen.dart';
import '../../features/auth/parent_linking_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/user_type_selection_screen.dart';
// Child Features
import '../../features/games/pronunciation/pronunciation_game_screen.dart';
import '../../features/games/sentence_building/sentence_building_game_screen.dart';
import '../../features/games/spelling/spelling_game_screen.dart';
import '../../features/games/word_matching/word_matching_game_screen.dart';
import '../../features/home/home_screen.dart';
// Parent Features
import '../../features/profile/profile_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Get arguments if they exist
    final args = settings.arguments as Map<String, dynamic>?;
    
    switch (settings.name) {
      // Auth Routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.userTypeSelection:
        return MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen());
      
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case AppRoutes.googleUserType:
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => GoogleUserTypeScreen(userData: args),
          );
        }
        return _errorRoute();
      
      case AppRoutes.parentLinking:
        return MaterialPageRoute(builder: (_) => const ParentLinkingScreen());
      
      case AppRoutes.childCompletion:
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => ChildCompletionScreen(userData: args),
          );
        }
        return _errorRoute();

      // Home & Settings Routes
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // Child Routes
      case AppRoutes.childDashboard:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case AppRoutes.pronunciation:
        return MaterialPageRoute(builder: (_) => const PronunciationGameScreen());
      
      case AppRoutes.sentenceBuilding:
        return MaterialPageRoute(builder: (_) => const SentenceBuildingGameScreen());
      
      case AppRoutes.spelling:
        return MaterialPageRoute(builder: (_) => const SpellingGameScreen());
      
      case AppRoutes.wordMatching:
        return MaterialPageRoute(builder: (_) => const WordMatchingGameScreen());

      // Parent Routes
      case AppRoutes.parentDashboard:
        return MaterialPageRoute(builder: (_) => const HomeScreen()); // Placeholder
      
      case AppRoutes.childrenManagement:
        return MaterialPageRoute(builder: (_) => const HomeScreen()); // Placeholder
      
      case AppRoutes.childDetails:
        return MaterialPageRoute(builder: (_) => const HomeScreen()); // Placeholder

      // Teacher Routes
      case AppRoutes.teacherDashboard:
        return MaterialPageRoute(builder: (_) => const HomeScreen()); // Placeholder
      
      case AppRoutes.createActivity:
        return MaterialPageRoute(builder: (_) => const HomeScreen()); // Placeholder

      // Admin Routes
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      case AppRoutes.userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());
      
      case AppRoutes.userDetails:
        return MaterialPageRoute(builder: (_) => const HomeScreen()); // Placeholder
      
      case AppRoutes.adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
      
      case AppRoutes.adminSettings:
        return MaterialPageRoute(builder: (_) => const AdminSettingsScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}