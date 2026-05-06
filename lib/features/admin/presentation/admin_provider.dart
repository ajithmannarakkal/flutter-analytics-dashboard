import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_model.dart';
import '../../../core/network/network_provider.dart';
import '../domain/admin_repository.dart';
import '../data/admin_repository_impl.dart';
import '../data/admin_remote_datasource.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final remoteDataSource = AdminRemoteDataSource(dioClient);
  return AdminRepositoryImpl(remoteDataSource);
});

final usersListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  // Fetch all users once
  return repo.getUsers();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredUsersProvider = Provider.autoDispose<AsyncValue<List<UserModel>>>((ref) {
  final usersAsync = ref.watch(usersListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return usersAsync.whenData((users) {
    if (query.isEmpty) return users;
    return users.where((user) {
      return user.name.toLowerCase().contains(query) || 
             user.email.toLowerCase().contains(query);
    }).toList();
  });
});

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
