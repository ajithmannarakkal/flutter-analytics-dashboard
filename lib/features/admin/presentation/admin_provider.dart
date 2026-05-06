import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_model.dart';
import '../domain/admin_repository.dart';
import '../data/mock_admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return MockAdminRepository();
});

final usersListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  return repo.getUsers(query: searchQuery);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final adminActionsProvider = Provider<AdminActions>((ref) {
  return AdminActions(ref);
});

class AdminActions {
  final Ref _ref;

  AdminActions(this._ref);

  Future<void> createUser(UserModel user, String password) async {
    final repo = _ref.read(adminRepositoryProvider);
    await repo.createUser(user, password);
    _ref.invalidate(usersListProvider);
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    final repo = _ref.read(adminRepositoryProvider);
    await repo.toggleUserStatus(userId, isActive);
    _ref.invalidate(usersListProvider);
  }

  Future<void> deleteUser(String userId) async {
    final repo = _ref.read(adminRepositoryProvider);
    await repo.deleteUser(userId);
    _ref.invalidate(usersListProvider);
  }

  Future<void> resetPassword(String userId, String newPassword) async {
    final repo = _ref.read(adminRepositoryProvider);
    await repo.resetPassword(userId, newPassword);
  }
}
