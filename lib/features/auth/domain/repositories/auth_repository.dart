import 'package:dartz/dartz.dart';
import 'package:readingquest_bilingual_learning/core/error/failures.dart';

import '../entities/register_params.dart';
import '../entities/user.dart';
import '../entities/user_type.dart';

abstract class AuthRepository {
  Future<User> getCurrentUser();

  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register(RegisterUserParams params);

  Future<Either<Failure, User>> signInWithGoogle({required UserType userType});

  Future<void> signOut();

  Future<void> deleteAccount();

  Stream<User?> get authStateChanges;

  Future<Either<Failure, bool>> checkParentExists(String parentEmail);
  Future<Either<Failure, User>> signUpWithExtendedData({
    required String email,
    required String password,
    required String name,
    required String username,
    required int age,
    required String? parentEmail,
    required UserType userType,
  });
  Future<Either<Failure, User>> completeUserProfile({
    required String userId,
    String? username,
    int? age,
    String? profileImageUrl,
  });
  Future<Either<Failure, User>> updateProfileImage(
      {required String userId, required String imageUrl});

}
