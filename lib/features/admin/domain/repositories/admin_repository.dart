import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminUser>> getAdminProfile(String adminId);
  Future<Either<Failure, AdminUser>> updateAdminProfile(AdminUser admin);
  Future<Either<Failure, Unit>> updatePermissions(
    String adminId,
    List<String> permissions,
  );
  Future<Either<Failure, Map<String, dynamic>>> getSystemStats();
  Future<Either<Failure, Unit>> manageUserStatus(String userId, bool isActive);
  Stream<Map<String, dynamic>> watchSystemMetrics();
  Future<Either<Failure, Map<String, dynamic>>> getDashboardData();
  Future<Either<Failure, Map<String, dynamic>>> getAnalyticsData();
  Future<Either<Failure, Map<String, dynamic>>> getTopUsers();
  Future<Either<Failure, Map<String, dynamic>>> getRecentActivities();
  Future<Either<Failure, List<AdminUser>>> getUsers({
    int limit,
    String? startAfter,
    //String? endBefore,
    int? page,
   String? userType,
  });
  Future<Either<Failure, Unit>> generateReport(String reportType);
  Future<Either<Failure, Unit>> updateSettings(Map<String, dynamic> settings);
  Future<Either<Failure, Unit>> manageContent(Map<String, dynamic> contentData);
  Future<Either<Failure, Unit>> sendNotification(
    String title,
    String message,
    List<String> userIds,
  );
  Future<Either<Failure, Unit>> resetUserProgress(String userId);
  //updateUserStatus
  Future<Either<Failure, Unit>> updateUserStatus({
    required String userId,
    required bool isActive,
  });
  Future<Either<Failure, Unit>> deleteUser(String userId);
  Stream<Map<String, dynamic>> watchSystemStatus();
  Stream<List<AdminUser>> watchUsersStream({
    int limit,
    String? startAfter,
    //String? endBefore,
    int? page,
     String? userType,
  });

}
