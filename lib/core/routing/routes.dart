class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String userTypeSelection = '/user-type-selection';
  static const String home = '/home';

  // Child Routes
  static const String pronunciationGame = '/games/pronunciation';
  static const String sentenceBuildingGame = '/games/sentence-building';
  static const String spellingGame = '/games/spelling';
  static const String wordMatchingGame = '/games/word-matching';

  // Parent Routes
  static const String parentDashboard = '/parent/dashboard';
  static const String childrenManagement = '/parent/children';

  // Teacher Routes
  static const String teacherDashboard = '/teacher/dashboard';
  static const String createActivity = '/teacher/activity/create';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  static const String adminUserDetails = '/admin/users/details';

  // Common Routes
  static const String profile = '/profile';
  static const String settings = '/settings';
}
