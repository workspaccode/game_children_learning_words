import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/admin_bloc.dart';

class UserActionsMenu extends StatelessWidget {

  const UserActionsMenu({
    super.key,
    required this.userId,
    required this.userName,
    required this.userRole,
  });
  final String userId;
  final String userName;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) {
        switch (value) {
          case 'edit':
            _showEditUserDialog(context);
            break;
          case 'delete':
            _showDeleteUserDialog(context);
            break;
          case 'reset_password':
            _showResetPasswordDialog(context);
            break;
          case 'view_details':
            _navigateToUserDetails(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit), title: Text('Edit User')),
        ),
        const PopupMenuItem<String>(
          value: 'reset_password',
          child: ListTile(
            leading: Icon(Icons.lock_reset),
            title: Text('Reset Password'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'view_details',
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text('View Details'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete User', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  void _showEditUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit details for user: $userName'),
              // Add form fields here
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                context.read<AdminBloc>().add(UpdateUserEvent(userId: userId));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Are you sure you want to delete user: $userName? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                context.read<AdminBloc>().add(DeleteUserEvent(userId: userId));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Text(
            'Are you sure you want to reset the password for user: $userName?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                context.read<AdminBloc>().add(
                  ResetUserPasswordEvent(userId: userId),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToUserDetails(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/admin/users/$userId',
      arguments: {'id': userId, 'username': userName, 'user_type': userRole},
    );
  }
}
