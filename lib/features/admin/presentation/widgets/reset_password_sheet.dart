import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/error_handler.dart';
import 'package:flutter_analytics_dashboard/features/auth/domain/user_model.dart';
import '../admin_provider.dart';

class ResetPasswordSheet extends StatefulWidget {
  final UserModel user;
  final AdminActions actions;
  final BuildContext parentContext;

  const ResetPasswordSheet({
    super.key,
    required this.user,
    required this.actions,
    required this.parentContext,
  });

  static Future<void> show({
    required BuildContext context,
    required UserModel user,
    required AdminActions actions,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ResetPasswordSheet(
        user: user,
        actions: actions,
        parentContext: context,
      ),
    );
  }

  @override
  State<ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
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
                  if (mounted) {
                    setState(() {
                      _error = ErrorHandler.getMessage(e);
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
