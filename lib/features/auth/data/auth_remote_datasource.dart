import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';


class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    
    // According to docs, response is { "success": true, "message": "...", "data": { "token": "...", "user": {...} } }
    final responseData = response.data['data'] as Map<String, dynamic>;
    return responseData;
  }
}
