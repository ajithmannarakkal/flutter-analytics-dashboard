import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  final List<UserModel> _mockUsers = const [
    UserModel(
      id: '1',
      email: 'admin@test.com',
      name: 'Admin User',
      role: Role.admin,
    ),
    UserModel(
      id: '2',
      email: 'user@test.com',
      name: 'Standard User',
      role: Role.user,
    ),
  ];

  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'admin@test.com' && password == 'admin123') {
      _currentUser = _mockUsers[0];
      return _currentUser!;
    } else if (email == 'user@test.com' && password == 'user123') {
      _currentUser = _mockUsers[1];
      return _currentUser!;
    }

    throw Exception('Invalid email or password');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }
}
