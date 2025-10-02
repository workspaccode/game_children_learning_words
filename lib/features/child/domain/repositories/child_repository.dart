import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/child_user.dart';

abstract class ChildRepository {
  Future<Either<Failure, ChildUser>> getChildProfile(String childId);
  Future<Either<Failure, ChildUser>> updateChildProfile(ChildUser child);
  Future<Either<Failure, Unit>> updateProgress(
    String childId,
    Map<String, int> progress,
  );
  Future<Either<Failure, int>> updateLevel(String childId, int level);
  Future<Either<Failure, List<ChildUser>>> getChildrenByParentId(
    String parentId,
  );
  Stream<ChildUser> watchChildProgress(String childId);
}
