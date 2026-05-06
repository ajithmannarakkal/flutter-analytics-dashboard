import '../../auth/domain/user_model.dart';
import '../domain/admin_repository.dart';
import 'admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<UserModel>> getUsers({String? query}) async {
    final response = await _remoteDataSource.getUsers(query: query);
    final data = response['data'] as List<dynamic>;
    return data.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<UserModel> createUser(UserModel user, String password) async {
    final payload = user.toJson();
    payload['password'] = password; // Add password for creation
    
    final response = await _remoteDataSource.createUser(payload);
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    await _remoteDataSource.toggleUserStatus(userId, isActive);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _remoteDataSource.deleteUser(userId);
  }

  @override
  Future<void> resetPassword(String userId, String newPassword) async {
    await _remoteDataSource.resetPassword(userId, newPassword);
  }
}
