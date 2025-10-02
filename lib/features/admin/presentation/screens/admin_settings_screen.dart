import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, 'System Settings', [
            _buildSettingTile(
              context,
              'Maintenance Mode',
              'Toggle system maintenance mode',
              Icons.build,
              trailing: Switch(
                value: false,
                onChanged: (value) => _toggleMaintenanceMode(context, value),
              ),
            ),
            _buildSettingTile(
              context,
              'Backup Settings',
              'Configure automatic backups',
              Icons.backup,
              onTap: () => _showBackupSettingsDialog(context),
            ),
            _buildSettingTile(
              context,
              'Performance Settings',
              'Configure system performance',
              Icons.speed,
              onTap: () => _showPerformanceSettingsDialog(context),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'User Management', [
            _buildSettingTile(
              context,
              'Registration Settings',
              'Configure user registration options',
              Icons.person_add,
              onTap: () => _showRegistrationSettingsDialog(context),
            ),
            _buildSettingTile(
              context,
              'Role Permissions',
              'Manage role-based permissions',
              Icons.security,
              onTap: () => _showRolePermissionsDialog(context),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Content Management', [
            _buildSettingTile(
              context,
              'Content Moderation',
              'Configure content moderation settings',
              Icons.content_paste,
              onTap: () => _showContentModerationDialog(context),
            ),
            _buildSettingTile(
              context,
              'File Storage',
              'Configure file storage settings',
              Icons.folder,
              onTap: () => _showFileStorageDialog(context),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Security Settings', [
            _buildSettingTile(
              context,
              'Authentication Settings',
              'Configure authentication methods',
              Icons.lock,
              onTap: () => _showAuthenticationSettingsDialog(context),
            ),
            _buildSettingTile(
              context,
              'Session Settings',
              'Configure session timeout and policies',
              Icons.timer,
              onTap: () => _showSessionSettingsDialog(context),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Notifications', [
            _buildSettingTile(
              context,
              'Email Notifications',
              'Configure email notification settings',
              Icons.email,
              onTap: () => _showEmailSettingsDialog(context),
            ),
            _buildSettingTile(
              context,
              'Push Notifications',
              'Configure push notification settings',
              Icons.notifications,
              onTap: () => _showPushNotificationSettingsDialog(context),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _toggleMaintenanceMode(BuildContext context, bool value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Maintenance Mode'),
          content: Text(
            value
                ? 'Are you sure you want to enable maintenance mode? This will prevent users from accessing the system.'
                : 'Are you sure you want to disable maintenance mode? This will restore user access to the system.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                // Update maintenance mode
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showBackupSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Backup Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Backup Frequency',
                  helperText: 'How often to perform backups',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Backup Location',
                  helperText: 'Where to store backups',
                ),
              ),
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
                // Save backup settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPerformanceSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Performance Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Cache Size',
                  helperText: 'Maximum cache size in MB',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Request Timeout',
                  helperText: 'Maximum request timeout in seconds',
                ),
                keyboardType: TextInputType.number,
              ),
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
                // Save performance settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRegistrationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Allow New Registrations'),
                value: true,
                onChanged: null,
              ),
              SwitchListTile(
                title: Text('Email Verification Required'),
                value: true,
                onChanged: null,
              ),
              SwitchListTile(
                title: Text('Admin Approval Required'),
                value: false,
                onChanged: null,
              ),
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
                // Save registration settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRolePermissionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Role Permissions'),
          content: const SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Save role permissions
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showContentModerationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Content Moderation'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Auto-moderate Content'),
                value: true,
                onChanged: null,
              ),
              SwitchListTile(
                title: Text('Profanity Filter'),
                value: true,
                onChanged: null,
              ),
              SwitchListTile(
                title: Text('Image Moderation'),
                value: true,
                onChanged: null,
              ),
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
                // Save content moderation settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFileStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('File Storage Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Maximum File Size',
                  helperText: 'Maximum file size in MB',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Allowed File Types',
                  helperText: 'Comma-separated list of file extensions',
                ),
              ),
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
                // Save file storage settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAuthenticationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Two-Factor Authentication'),
                value: true,
                onChanged: null,
              ),
              SwitchListTile(
                title: Text('Social Login'),
                value: true,
                onChanged: null,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Minimum Password Length',
                  helperText: 'Minimum number of characters',
                ),
                keyboardType: TextInputType.number,
              ),
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
                // Save authentication settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSessionSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Session Timeout',
                  helperText: 'Timeout in minutes',
                ),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: Text('Force Single Session'),
                value: false,
                onChanged: null,
              ),
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
                // Save session settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEmailSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'SMTP Server'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'SMTP Port'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Email From'),
              ),
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
                // Save email settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPushNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Push Notification Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Enable Push Notifications'),
                value: true,
                onChanged: null,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Firebase Server Key'),
              ),
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
                // Save push notification settings
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
