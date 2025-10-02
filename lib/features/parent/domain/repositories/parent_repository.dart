import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../child/domain/entities/child_user.dart';
import '../entities/parent_user.dart';

abstract class ParentRepository {
  Future<Either<Failure, ParentUser>> getParentProfile(String parentId);
  Future<Either<Failure, ParentUser>> updateParentProfile(ParentUser parent);
  Future<Either<Failure, Unit>> addChild(String parentId, String childId);
  Future<Either<Failure, Unit>> removeChild(String parentId, String childId);
  Future<Either<Failure, List<ChildUser>>> getChildren(String parentId);
  Future<Either<Failure, Unit>> updatePaymentInfo(
    String parentId,
    Map<String, dynamic> paymentInfo,
  );
  Stream<List<ChildUser>> watchChildren(String parentId);
}
