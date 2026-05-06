import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/widgets/action_confirm_sheet.dart';
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
    final usersAsync = ref.watch(filteredUsersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ActionConfirmSheet.show(
                context: context,
                title: 'Logout',
                message: 'Are you sure you want to logout?',
                confirmLabel: 'Logout',
                confirmColor: Colors.red,
                onConfirm: () => ref.read(authStateProvider.notifier).logout(),
              );
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
                ref.read(searchQueryProvider.notifier).state = val;
              },
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
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
        onPressed: () => context.push('/admin/create-user'),
        child: const Icon(Icons.add),
      ),
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
                    ActionConfirmSheet.show(
                      context: context,
                      title: user.isActive ? 'Disable User' : 'Enable User',
                      message: 'Are you sure you want to ${user.isActive ? 'disable' : 'enable'} ${user.name}?',
                      confirmLabel: user.isActive ? 'Disable' : 'Enable',
                      confirmColor: user.isActive ? Colors.red : Colors.green,
                      onConfirm: () async {
                        try {
                          await actions.toggleUserStatus(user.id, !user.isActive);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('User ${user.isActive ? 'disabled' : 'enabled'} successfully')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            String errorMessage = e.toString();
                            if (e is ApiException) {
                              errorMessage = e.message;
                            } else if (e is DioException && e.error is ApiException) {
                              errorMessage = (e.error as ApiException).message;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                    );
                    break;
                  case 'delete':
                    ActionConfirmSheet.show(
                      context: context,
                      title: 'Delete User',
                      message: 'Are you sure you want to permanently delete ${user.name}?',
                      confirmLabel: 'Delete',
                      confirmColor: Colors.red,
                      onConfirm: () async {
                        try {
                          await actions.deleteUser(user.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User deleted successfully')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            String errorMessage = e.toString();
                            if (e is ApiException) {
                              errorMessage = e.message;
                            } else if (e is DioException && e.error is ApiException) {
                              errorMessage = (e.error as ApiException).message;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                    );
                    break;
                  case 'reset':
                    _showResetPasswordSheet(context, user, actions);
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

  void _showResetPasswordSheet(BuildContext context, UserModel user, AdminActions actions) {
    final passwordCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return _ResetPasswordSheetContent(
            user: user,
            actions: actions,
            parentContext: context,
          );
        },
      ),
    );
  }
}

class _ResetPasswordSheetContent extends StatefulWidget {
  final UserModel user;
  final AdminActions actions;
  final BuildContext parentContext;

  const _ResetPasswordSheetContent({
    required this.user,
    required this.actions,
    required this.parentContext,
  });

  @override
  State<_ResetPasswordSheetContent> createState() => _ResetPasswordSheetContentState();
}

class _ResetPasswordSheetContentState extends State<_ResetPasswordSheetContent> {
  final _passwordCtrl = TextEditingController();
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Text(
            'Reset Password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter new password for ${widget.user.name}',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            autofocus: true,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : () async {
              if (_passwordCtrl.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                try {
                  await widget.actions.resetPassword(widget.user.id, _passwordCtrl.text.trim());
                  if (mounted && widget.parentContext.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                      const SnackBar(content: Text('Password reset successfully')),
                    );
                  }
                } catch (e) {
                  String errorMessage = e.toString();
                  if (e is ApiException) {
                    errorMessage = e.message;
                  } else if (e is DioException && e.error is ApiException) {
                    errorMessage = (e.error as ApiException).message;
                  }
                  
                  if (mounted) {
                    setState(() {
                      _error = errorMessage;
                      _isLoading = false;
                    });
                  }
                }
              }
            },
            child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Reset Password'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
