import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_provider.dart';
import 'admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  ref.read(searchQueryProvider.notifier).state = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context, WidgetRef ref) {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    Role selectedRole = Role.user;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    DropdownButton<Role>(
                      value: selectedRole,
                      isExpanded: true,
                      items: Role.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRole = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty && passwordCtrl.text.isNotEmpty) {
                      final newUser = UserModel(
                        id: '', // Generated by repo
                        email: emailCtrl.text.trim(),
                        name: nameCtrl.text.trim(),
                        role: selectedRole,
                      );
                      ref.read(adminActionsProvider).createUser(newUser, passwordCtrl.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class UserCard extends ConsumerWidget {
  final UserModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actions = ref.read(adminActionsProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: user.isActive ? null : theme.cardTheme.color?.withValues(alpha: 0.6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive 
              ? (user.role == Role.admin ? theme.colorScheme.secondary : theme.colorScheme.primary)
              : Colors.grey,
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.name, 
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 16,
            color: user.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          '${user.email} • ${user.role.name}',
          style: TextStyle(color: user.isActive ? null : Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.isActive ? 'Active' : 'Disabled',
                style: TextStyle(
                  color: user.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'toggle':
                    actions.toggleUserStatus(user.id, !user.isActive);
                    break;
                  case 'delete':
                    _confirmDelete(context, user, actions);
                    break;
                  case 'reset':
                    _showResetPasswordDialog(context, user, actions);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(user.isActive ? 'Disable User' : 'Enable User'),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('Reset Password'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete User', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user, AdminActions actions) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              actions.deleteUser(user.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, UserModel user, AdminActions actions) {
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Password for ${user.name}'),
        content: TextField(
          controller: passwordCtrl,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (passwordCtrl.text.isNotEmpty) {
                try {
                  await actions.resetPassword(user.id, passwordCtrl.text.trim());
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
