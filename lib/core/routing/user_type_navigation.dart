import 'package:flutter/material.dart';
import 'package:readingquest_bilingual_learning/core/routing/app_routes.dart';
import 'package:readingquest_bilingual_learning/core/services/navigation_service.dart';
import 'package:readingquest_bilingual_learning/services/auth_service.dart';

class UserTypeRouter {
  static void routeUserByType(BuildContext context, UserType userType) {
    switch (userType) {
      case UserType.child:
        // توجيه الطفل إلى الشاشة الرئيسية للألعاب
        NavigationService().navigateToAndClear(AppRoutes.childDashboard);
        break;
      case UserType.parent:
        // توجيه ولي الأمر إلى شاشة متابعة الأطفال
        NavigationService().navigateToAndClear(AppRoutes.parentDashboard);
        break;
      case UserType.teacher:
        // توجيه المعلم إلى شاشة إدارة الفصول
        NavigationService().navigateToAndClear(AppRoutes.teacherDashboard);
        break;
      default:
        // في حالة وجود خطأ، توجيه المستخدم إلى شاشة تسجيل الدخول
        NavigationService().navigateToAndClear(AppRoutes.login);
    }
  }

  static String getInitialRouteByUserType(UserType userType) {
    switch (userType) {
      case UserType.child:
        return AppRoutes.childDashboard;
      case UserType.parent:
        return AppRoutes.parentDashboard;
      case UserType.teacher:
        return AppRoutes.teacherDashboard;
      default:
        return AppRoutes.login;
    }
  }

  static bool canAccessRoute(String route, UserType userType) {
    if (route.startsWith('/child/') && userType != UserType.child) {
      return false;
    }
    if (route.startsWith('/parent/') && userType != UserType.parent) {
      return false;
    }
    if (route.startsWith('/teacher/') && userType != UserType.teacher) {
      return false;
    }
    return true;
  }
}