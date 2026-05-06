import '../../auth/domain/user_model.dart';
import '../domain/admin_repository.dart';

class MockAdminRepository implements AdminRepository {
  final List<UserModel> _users = [
    const UserModel(id: '1', email: 'admin@test.com', name: 'Admin User', role: Role.admin),
    const UserModel(id: '2', email: 'user@test.com', name: 'Standard User', role: Role.user),
    const UserModel(id: '3', email: 'jane@example.com', name: 'Jane Doe', role: Role.user),
    const UserModel(id: '4', email: 'john@example.com', name: 'John Smith', role: Role.user, isActive: false),
    const UserModel(id: '5', email: 'manager@example.com', name: 'Project Manager', role: Role.user),
  ];

  @override
  Future<List<UserModel>> getUsers({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (query == null || query.isEmpty) {
      return List.from(_users);
    }
    final lowerQuery = query.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) || user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<UserModel> createUser(UserModel user, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newUser = user.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    _users.add(newUser);
    return newUser;
  }

  @override
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: isActive);
    } else {
      throw Exception('User not found');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final initialLength = _users.length;
    _users.removeWhere((u) => u.id == userId);
    if (_users.length == initialLength) {
      throw Exception('User not found');
    }
  }

  @override
  Future<void> resetPassword(String userId, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('User not found');
    }
    // In a real app, you would hash the password and update it in DB
  }
}
