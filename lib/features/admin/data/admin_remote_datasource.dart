import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';

class AdminRemoteDataSource {
  final DioClient _dioClient;

  AdminRemoteDataSource(this._dioClient);

  Future<Map<String, dynamic>> getUsers({String? query}) async {
    final response = await _dioClient.get(
      ApiConstants.users,
      queryParameters: query != null && query.isNotEmpty ? {'search': query} : null,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await _dioClient.post(
      ApiConstants.users,
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> toggleUserStatus(String userId, bool isActive) async {
    final response = await _dioClient.put(
      ApiConstants.disableUser(userId),
      data: {'isActive': isActive},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    final response = await _dioClient.delete(
      ApiConstants.deleteUser(userId),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword(String userId, String newPassword) async {
    final response = await _dioClient.put(
      ApiConstants.resetPassword(userId),
      data: {'newPassword': newPassword},
    );
    return response.data as Map<String, dynamic>;
  }
}
