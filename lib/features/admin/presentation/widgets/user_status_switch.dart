import 'package:flutter/material.dart';

class UserStatusSwitch extends StatelessWidget {

  const UserStatusSwitch({
    super.key,
    required this.isActive,
    required this.onChanged,
  });
  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isActive,
      onChanged: (value) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(value ? 'Activate User' : 'Deactivate User'),
              content: Text(
                value
                    ? 'Are you sure you want to activate this user?'
                    : 'Are you sure you want to deactivate this user? They will not be able to access the system.',
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () {
                    onChanged(value);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      activeThumbColor: Theme.of(context).colorScheme.primary,
      inactiveThumbColor: Colors.grey,
    );
  }
}
