import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../child/data/models/child_user_model.dart';
import '../../data/models/parent_user_model.dart';
import '../../domain/entities/parent_user.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentRepositoryImpl implements ParentRepository {
  ParentRepositoryImpl(this._firestore)
    : _usersCollection = _firestore.collection('users');
  final FirebaseFirestore _firestore;
  final CollectionReference _usersCollection;

  @override
  Future<Either<Failure, ParentUser>> getParentProfile(String parentId) async {
    try {
      final doc = await _usersCollection.doc(parentId).get();
      if (!doc.exists) {
        return const Left(AuthFailure('Parent profile not found'));
      }

      return Right(
        ParentUserModel.fromJson({
          ...doc.data()! as Map<String, dynamic>,
          'id': doc.id,
        }),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParentUser>> updateParentProfile(
    ParentUser parent,
  ) async {
    try {
      final parentModel = parent as ParentUserModel;
      await _usersCollection.doc(parent.id).update(parentModel.toJson());
      return Right(parent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addChild(
    String parentId,
    String childId,
  ) async {
    try {
      final batch = _firestore.batch();

      // Update parent's children list
      batch.update(_usersCollection.doc(parentId), {
        'children': FieldValue.arrayUnion([childId]),
      });

      // Update child's parent reference
      batch.update(_usersCollection.doc(childId), {'parentId': parentId});

      await batch.commit();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeChild(
    String parentId,
    String childId,
  ) async {
    try {
      final batch = _firestore.batch();

      // Remove child from parent's children list
      batch.update(_usersCollection.doc(parentId), {
        'children': FieldValue.arrayRemove([childId]),
      });

      // Remove parent reference from child
      batch.update(_usersCollection.doc(childId), {'parentId': null});

      await batch.commit();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChildUser>>> getChildren(String parentId) async {
    try {
      final snapshot = await _usersCollection
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
  Future<Either<Failure, Unit>> updatePaymentInfo(
    String parentId,
    Map<String, dynamic> paymentInfo,
  ) async {
    try {
      await _usersCollection.doc(parentId).update({'paymentInfo': paymentInfo});
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ChildUser>> watchChildren(String parentId) {
    return _usersCollection
        .where('role', isEqualTo: 'child')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => ChildUserModel.fromJson({
                  ...doc.data()! as Map<String, dynamic>,
                  'id': doc.id,
                }),
              )
              .toList();
        });
  }
}
