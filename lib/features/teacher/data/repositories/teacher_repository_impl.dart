import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/entities/teacher_user.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_local_datasource.dart';
import '../models/student_profile_model.dart';
import '../models/teacher_user_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  TeacherRepositoryImpl({
    required FirebaseFirestore firestore,
    required TeacherLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _firestore = firestore,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _usersCollection = firestore.collection('users');

  final FirebaseFirestore _firestore;
  final TeacherLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final CollectionReference _usersCollection;

  @override
  Future<Either<Failure, TeacherUser>> getTeacherProfile(
    String teacherId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final doc = await _usersCollection.doc(teacherId).get();
        if (!doc.exists) {
          return const Left(AuthFailure('Teacher profile not found'));
        }

        final teacher = TeacherUserModel.fromJson({
          ...doc.data()! as Map<String, dynamic>,
          'id': doc.id,
        });

        await _localDataSource.cacheTeacherUser(teacher.toJson());
        return Right(teacher);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final teacherData = await _localDataSource.getLastTeacher();
        final teacher = TeacherUserModel.fromJson(teacherData);
        return Right(teacher);
      } on CacheException {
        return const Left(CacheFailure('No cached teacher profile found'));
      }
    }
  }

  @override
  Future<Either<Failure, TeacherUser>> updateTeacherProfile(
    TeacherUser teacher,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final teacherModel = teacher as TeacherUserModel;
        await _usersCollection.doc(teacher.id).update(teacherModel.toJson());
        await _localDataSource.cacheTeacherUser(teacherModel.toJson());
        return Right(teacher);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addSubject(
    String teacherId,
    String subject,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        await _usersCollection.doc(teacherId).update({
          'subjects': FieldValue.arrayUnion([subject]),
        });

        // Update local cache
        try {
          final cachedTeacher = await _localDataSource.getLastTeacher();
          final subjects = List<String>.from(cachedTeacher['subjects'] as List);
          if (!subjects.contains(subject)) {
            subjects.add(subject);
            await _localDataSource.cacheTeacherUser({
              ...cachedTeacher,
              'subjects': subjects,
            });
          }
        } catch (e) {
          // Cache update failed but online operation succeeded
          // Not a critical error, so we continue
        }

        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeSubject(
    String teacherId,
    String subject,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        await _usersCollection.doc(teacherId).update({
          'subjects': FieldValue.arrayRemove([subject]),
        });

        // Update local cache
        try {
          final cachedTeacher = await _localDataSource.getLastTeacher();
          final subjects = List<String>.from(cachedTeacher['subjects'] as List)
            ..remove(subject);
          await _localDataSource.cacheTeacherUser({
            ...cachedTeacher,
            'subjects': subjects,
          });
        } catch (e) {
          // Cache update failed but online operation succeeded
          // Not a critical error, so we continue
        }

        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addClass(
    String teacherId,
    String classId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        await _usersCollection.doc(teacherId).update({
          'classes': FieldValue.arrayUnion([classId]),
        });

        // Update local cache
        try {
          final cachedTeacher = await _localDataSource.getLastTeacher();
          final classes = List<String>.from(cachedTeacher['classes'] as List);
          if (!classes.contains(classId)) {
            classes.add(classId);
            await _localDataSource.cacheTeacherUser({
              ...cachedTeacher,
              'classes': classes,
            });
          }
        } catch (e) {
          // Cache update failed but online operation succeeded
          // Not a critical error, so we continue
        }

        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeClass(
    String teacherId,
    String classId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        await _usersCollection.doc(teacherId).update({
          'classes': FieldValue.arrayRemove([classId]),
        });

        // Update local cache
        try {
          final cachedTeacher = await _localDataSource.getLastTeacher();
          final classes = List<String>.from(cachedTeacher['classes'] as List)
            ..remove(classId);
          await _localDataSource.cacheTeacherUser({
            ...cachedTeacher,
            'classes': classes,
          });

          // Also clear cached students for this class
          await _localDataSource.clearStudents();
        } catch (e) {
          // Cache update failed but online operation succeeded
          // Not a critical error, so we continue
        }

        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<StudentProfile>>> getClassStudents(
    String classId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final snapshot = await _firestore
            .collection('classes')
            .doc(classId)
            .collection('students')
            .get();

        final students = snapshot.docs.map((doc) {
          return StudentProfileModel.fromJson({...doc.data(), 'id': doc.id});
        }).toList();

        await _localDataSource.cacheStudents(
          students.map((s) => s.toJson()).toList(),
        );
        return Right(students);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final jsonList = await _localDataSource.getLastStudents();
        final students = jsonList
            .map(StudentProfileModel.fromJson)
            .toList();
        return Right(students);
      } on CacheException {
        return const Left(CacheFailure('No cached students found'));
      }
    }
  }

  @override
  Stream<TeacherUser> watchTeacherProfile(String teacherId) {
    return _usersCollection.doc(teacherId).snapshots().map((doc) {
      if (!doc.exists) {
        throw AuthenticationException('Teacher profile not found');
      }

      final teacher = TeacherUserModel.fromJson({
        ...doc.data()! as Map<String, dynamic>,
        'id': doc.id,
      });

      // Cache the profile asynchronously
      _localDataSource.cacheTeacherUser(teacher.toJson());

      return teacher;
    });
  }
}
