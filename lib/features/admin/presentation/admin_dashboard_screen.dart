import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/widgets/action_confirm_sheet.dart';
import 'admin_provider.dart';
import 'widgets/user_card.dart';

/// The main dashboard for administrators to manage users.
/// Provides functionality for searching, creating, and managing user accounts.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(filteredUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context, ref),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const _AdminSearchBar(),
              Expanded(
                child: usersAsync.when(
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return UserCard(key: ValueKey(user.id), user: user);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/create-user'),
        tooltip: 'Create New User',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ActionConfirmSheet.show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      confirmColor: Colors.red,
      onConfirm: () => ref.read(authStateProvider.notifier).logout(),
    );
  }
}

class _AdminSearchBar extends ConsumerWidget {
  const _AdminSearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (val) {
          ref.read(searchQueryProvider.notifier).state = val;
        },
        decoration: const InputDecoration(
          hintText: 'Search users by name or email...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
