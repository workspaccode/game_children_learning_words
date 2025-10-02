import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/services/auth_service.dart';

import 'app_routes.dart';

class UserTypeRouter {
  static void routeUserByType(BuildContext context, UserType userType) {
    switch (userType) {
      case UserType.child:
        // توجيه الطفل إلى الشاشة الرئيسية للألعاب
        context.go(AppRoutes.childDashboard);
        break;
      case UserType.parent:
        // توجيه ولي الأمر إلى شاشة متابعة الأطفال
        context.go(AppRoutes.parentDashboard);
        break;
      case UserType.teacher:
        // توجيه المعلم إلى شاشة إدارة الفصول
        context.go(AppRoutes.teacherDashboard);
        break;
      default:
        // في حالة وجود خطأ، توجيه المستخدم إلى شاشة تسجيل الدخول
        context.go('/login');
    }
  }

  static String getInitialRouteByUserType(UserType userType) {
    switch (userType) {
      case UserType.child:
        return '/child/home';
      case UserType.parent:
        return '/parent/dashboard';
      case UserType.teacher:
        return '/teacher/classes';
      default:
        return '/login';
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
