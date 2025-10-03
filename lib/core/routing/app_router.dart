import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/child_completion_screen.dart';
import '../../features/auth/google_user_type_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/parent_linking_screen.dart';
import '../../features/auth/register_screen.dart';
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
import '../../features/teacher_dashboard/teacher_dashboard_screen_new.dart';
import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash Route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.userTypeSelection,
        name: 'userTypeSelection',
        builder: (context, state) => const UserTypeSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.googleUserType,
        name: 'googleUserType',
        builder: (context, state) {
          final userData = state.extra as Map<String, dynamic>? ?? {};
          return GoogleUserTypeScreen(userData: userData);
        },
      ),
      GoRoute(
        path: AppRoutes.parentLinking,
        name: 'parentLinking',
        builder: (context, state) => const ParentLinkingScreen(),
      ),
      GoRoute(
        path: AppRoutes.childCompletion,
        name: 'childCompletion',
        builder: (context, state) {
          final userData = state.extra as Map<String, dynamic>? ?? {};
          return ChildCompletionScreen(userData: userData);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Dashboard Routes
      GoRoute(
        path: AppRoutes.parentDashboard,
        name: 'parentDashboard',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherDashboard,
        name: 'teacherDashboard',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.childDashboard,
        name: 'childDashboard',
        builder: (context, state) => const HomeScreen(),
      ),

      // Parent Routes
      GoRoute(
        path: AppRoutes.childrenManagement,
        name: 'childrenManagement',
        builder: (context, state) => const ChildrenManagementScreen(),
      ),

      // Teacher Routes
      GoRoute(
        path: AppRoutes.createActivity,
        name: 'createActivity',
        builder: (context, state) => const CreateActivityScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Game Routes
      GoRoute(
        path: AppRoutes.wordMatching,
        name: 'wordMatching',
        builder: (context, state) => const WordMatchingGameScreen(),
      ),
      GoRoute(
        path: AppRoutes.sentenceBuilding,
        name: 'sentenceBuilding',
        builder: (context, state) => const SentenceBuildingGameScreen(),
      ),
      GoRoute(
        path: AppRoutes.pronunciation,
        name: 'pronunciation',
        builder: (context, state) => const PronunciationGameScreen(),
      ),
      GoRoute(
        path: AppRoutes.spelling,
        name: 'spelling',
        builder: (context, state) => const SpellingGameScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
