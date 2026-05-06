import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/action_confirm_sheet.dart';
import '../../../../core/utils/error_handler.dart';
import 'package:flutter_analytics_dashboard/features/auth/domain/user_model.dart';
import '../admin_provider.dart';
import 'reset_password_sheet.dart';

class UserCard extends ConsumerWidget {
  final UserModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actions = ref.read(adminActionsProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: user.isActive ? null : theme.cardTheme.color?.withOpacity(0.6),
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
            _StatusBadge(isActive: user.isActive),
            _UserActionMenu(user: user, actions: actions),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Disabled',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _UserActionMenu extends StatelessWidget {
  final UserModel user;
  final AdminActions actions;

  const _UserActionMenu({required this.user, required this.actions});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleAction(context, value),
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
    );
  }

  void _handleAction(BuildContext context, String value) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ErrorHandler.getMessage(e)), backgroundColor: Colors.red),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ErrorHandler.getMessage(e)), backgroundColor: Colors.red),
                );
              }
            }
          },
        );
        break;
      case 'reset':
        ResetPasswordSheet.show(context: context, user: user, actions: actions);
        break;
    }
  }
}
