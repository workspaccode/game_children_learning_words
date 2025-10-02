import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/child_user_model.dart';
import '../../domain/entities/child_user.dart';
import '../../domain/repositories/child_repository.dart';

class ChildRepositoryImpl implements ChildRepository {
  ChildRepositoryImpl(this._firestore)
    : _childrenCollection = _firestore.collection('users');
  final FirebaseFirestore _firestore;
  final CollectionReference _childrenCollection;

  @override
  Future<Either<Failure, ChildUser>> getChildProfile(String childId) async {
    try {
      final doc = await _childrenCollection.doc(childId).get();
      if (!doc.exists) {
        return const Left(AuthFailure('Child profile not found'));
      }

      return Right(
        ChildUserModel.fromJson({
          ...doc.data()! as Map<String, dynamic>,
          'id': doc.id,
        }),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChildUser>> updateChildProfile(ChildUser child) async {
    try {
      final childModel = child as ChildUserModel;
      await _childrenCollection.doc(child.id).update(childModel.toJson());
      return Right(child);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProgress(
    String childId,
    Map<String, int> progress,
  ) async {
    try {
      await _childrenCollection.doc(childId).update({'progress': progress});
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateLevel(String childId, int level) async {
    try {
      await _childrenCollection.doc(childId).update({'level': level});
      return Right(level);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChildUser>>> getChildrenByParentId(
    String parentId,
  ) async {
    try {
      final snapshot = await _childrenCollection
          .where('role', isEqualTo: 'child')
          .where('parentId', isEqualTo: parentId)
          .get();

      final children = snapshot.docs
          .map(
            (doc) => ChildUserModel.fromJson({
              ...doc.data()! as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();

      return Right(children);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<ChildUser> watchChildProgress(String childId) {
    return _childrenCollection.doc(childId).snapshots().map((doc) {
      return ChildUserModel.fromJson({
        ...doc.data()! as Map<String, dynamic>,
        'id': doc.id,
      });
    });
  }
}
