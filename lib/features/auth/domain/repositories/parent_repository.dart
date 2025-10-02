import 'package:readingquest_bilingual_learning/features/parent/data/models/parent_user_model.dart';

abstract class ParentRepository {
  // Repository methods here
  Future<void> createParent(ParentUserModel parent);
  Future<ParentUserModel?> getParentById(String id);
  Future<List<ParentUserModel>> getAllParents();
  Future<void> updateParent(ParentUserModel parent);
  Future<void> deleteParent(String id);
  Future<void> loginParent(String email, String password);
  Future<void> logoutParent();
  
}