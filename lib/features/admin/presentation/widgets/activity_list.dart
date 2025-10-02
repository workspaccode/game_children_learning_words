import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityList extends StatelessWidget {

  const ActivityList({super.key, required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Card(
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final timestamp = DateTime.parse(activity['timestamp'] as String);

            return ListTile(
              leading: _getActivityIcon(activity['type'] as String),
              title: Text(activity['description'] as String),
              subtitle: Text(
                timeago.format(timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: _getActivityStatus(activity['status'] as String),
            );
          },
        ),
      ),
    );
  }

  Widget _getActivityIcon(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'login':
        iconData = Icons.login;
        iconColor = Colors.blue;
        break;
      case 'content_update':
        iconData = Icons.edit;
        iconColor = Colors.orange;
        break;
      case 'user_update':
        iconData = Icons.person;
        iconColor = Colors.green;
        break;
      case 'system':
        iconData = Icons.settings;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _getActivityStatus(String status) {
    Color color;
    String text;

    switch (status) {
      case 'success':
        color = Colors.green;
        text = 'Success';
        break;
      case 'error':
        color = Colors.red;
        text = 'Error';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
