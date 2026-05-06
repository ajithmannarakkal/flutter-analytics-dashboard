import 'dart:convert';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';
import 'auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;

  AuthRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<UserModel> login(String email, String password) async {
    final data = await _remoteDataSource.login(email, password);
    
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    
    // Save token
    await _storageService.saveToken(token);
    
    final user = UserModel.fromJson(userJson);
    return user;
  }

  @override
  Future<void> logout() async {
    await _storageService.deleteToken();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      // In a real app, you might validate the token with the backend here,
      // or decode the JWT to extract user info if the backend doesn't have a /me endpoint.
      // Since the API docs don't show a /me endpoint, we can decode the JWT to get role/email 
      // or just assume they are valid until a 401 occurs.
      
      // Let's decode the token manually to restore user info.
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
          
          return UserModel(
            id: payloadMap['id'] ?? '',
            email: payloadMap['email'] ?? '',
            name: payloadMap['name'] ?? 'Restored User',
            role: payloadMap['role'] == 'admin' ? Role.admin : Role.user,
          );
        }
      } catch (e) {
        // If decoding fails, clear token and return null
        await _storageService.deleteToken();
      }
    }
    return null;
  }
}
