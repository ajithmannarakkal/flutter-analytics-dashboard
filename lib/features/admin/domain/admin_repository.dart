import '../../auth/domain/user_model.dart';

abstract class AdminRepository {
  Future<List<UserModel>> getUsers({String? query});
  Future<UserModel> createUser(UserModel user, String password);
  Future<void> toggleUserStatus(String userId, bool isActive);
  Future<void> deleteUser(String userId);
  Future<void> resetPassword(String userId, String newPassword);
}
