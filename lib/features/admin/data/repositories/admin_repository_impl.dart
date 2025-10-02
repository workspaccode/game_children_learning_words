import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:readingquest_bilingual_learning/core/error/failures.dart';
import 'package:readingquest_bilingual_learning/features/admin/domain/entities/admin_user.dart';
import 'package:readingquest_bilingual_learning/features/admin/domain/repositories/admin_repository.dart';

import '../../data/models/admin_user_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._firestore)
    : _usersCollection = _firestore.collection('users');
  final FirebaseFirestore _firestore;
  final CollectionReference _usersCollection;

  @override
  Future<Either<Failure, AdminUser>> getAdminProfile(String adminId) async {
    try {
      final doc = await _usersCollection.doc(adminId).get();
      if (!doc.exists) {
        return const Left(AuthFailure('Admin profile not found'));
      }

      return Right(
        AdminUserModel.fromJson({
          ...doc.data()! as Map<String, dynamic>,
          'id': doc.id,
        }),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> updateAdminProfile(AdminUser admin) async {
    try {
      final adminModel = admin as AdminUserModel;
      await _usersCollection.doc(admin.id).update(adminModel.toJson());
      return Right(admin);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePermissions(
    String adminId,
    List<String> permissions,
  ) async {
    try {
      await _usersCollection.doc(adminId).update({'permissions': permissions});
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSystemStats() async {
    try {
      final stats = await _firestore
          .collection('system_stats')
          .doc('current')
          .get();
      if (!stats.exists) {
        return const Left(ServerFailure('System stats not found'));
      }
      return Right(stats.data() ?? {});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> manageUserStatus(
    String userId,
    bool isActive,
  ) async {
    try {
      await _usersCollection.doc(userId).update({'isActive': isActive});
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Map<String, dynamic>> watchSystemMetrics() {
    return _firestore
        .collection('system_stats')
        .doc('current')
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardData() async {
    try {
      final snapshot = await _firestore
          .collection('dashboard')
          .doc('summary')
          .get();
      if (!snapshot.exists) {
        return const Left(ServerFailure('Dashboard data not found'));
      }
      return Right(snapshot.data() ?? {});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> generateReport(String reportType) async {
    try {
      await _firestore.collection('reports').add({
        'type': reportType,
        'generatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore
          .collection('settings')
          .doc('app_settings')
          .update(settings);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> manageContent(
    Map<String, dynamic> contentData,
  ) async {
    try {
      final action = contentData['action'] as String;
      final contentId = contentData['contentId'] as String;
      final data = contentData['data'] as Map<String, dynamic>?;

      switch (action) {
        case 'create':
          if (data != null) {
            await _firestore.collection('content').doc(contentId).set(data);
          }
          break;
        case 'update':
          if (data != null) {
            await _firestore.collection('content').doc(contentId).update(data);
          }
          break;
        case 'delete':
          await _firestore.collection('content').doc(contentId).delete();
          break;
        default:
          return const Left(ServerFailure('Invalid action'));
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Map<String, dynamic>> watchSystemStatus() {
    return _firestore
        .collection('system_status')
        .doc('current')
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  @override
  Future<Either<Failure, List<AdminUser>>> getUsers({
    String? userType,
    String? startAfter,
    int? page,
    int limit = 10,
  }) async {
    try {
      Query query = _usersCollection;

      if (userType != null && userType != 'all') {
        query = query.where('role', isEqualTo: userType);
      }

      if (startAfter != null) {
        final startAfterDoc = await _usersCollection.doc(startAfter).get();
        if (startAfterDoc.exists) {
          query = query.startAfterDocument(startAfterDoc);
        }
      } else if (page != null) {
        final startAt = (page - 1) * limit;
        query = query.startAt([startAt]);
      }

      final QuerySnapshot snapshot = await query
          .orderBy('name')
          .limit(limit)
          .get();

      return Right(
        snapshot.docs
            .map(
              (doc) => AdminUserModel.fromJson({
                ...doc.data()! as Map<String, dynamic>,
                'id': doc.id,
              }),
            )
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAnalyticsData() async {
    try {
      final snapshot = await _firestore
          .collection('analytics')
          .doc('summary')
          .get();

      return Right(snapshot.data() ?? {});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTopUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      final users = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      return Right({'users': users});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRecentActivities() async {
    try {
      final snapshot = await _firestore
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      final activities = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      return Right({'activities': activities});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendNotification(
    String title,
    String message,
    List<String> userIds,
  ) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'userIds': userIds,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetUserProgress(String userId) async {
    try {
      await _firestore.collection('user_progress').doc(userId).set({
        'reset_at': FieldValue.serverTimestamp(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    try {
      await _usersCollection.doc(userId).update({'isActive': isActive});
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<AdminUser>> watchUsersStream({
    int limit = 10,
    String? startAfter,
    int? page,
    String? userType,
  }) {
    Query query = _usersCollection;

    if (userType != null && userType != 'all') {
      query = query.where('role', isEqualTo: userType);
    }

    return query
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AdminUserModel.fromJson({
                  ...doc.data()! as Map<String, dynamic>,
                  'id': doc.id,
                }),
              )
              .toList(),
        );
  }
}
