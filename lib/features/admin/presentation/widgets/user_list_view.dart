import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/admin_bloc.dart';
import 'user_actions_menu.dart';
import 'user_status_switch.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  String _selectedUserType = 'all'; // 'all', 'child', 'parent', or 'teacher'

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const AdminLoadUsersEvent(userType: 'all'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildUserTypeFilter(),
        Expanded(
          child: BlocBuilder<AdminBloc, AdminState>(
            builder: (context, state) {
              if (state is AdminLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminError) {
                return Center(child: Text(state.message));
              }
              if (state is AdminUsersLoaded) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, size: 100, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        'Child: ${state.child.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Parent: ${state.parent.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Teacher: ${state.teacher.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text('No data available'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'all',
            label: Text('All'),
          ),
          ButtonSegment(
            value: 'child',
            label: Text('Children'),
          ),
          ButtonSegment(
            value: 'parent',
            label: Text('Parents'),
          ),
          ButtonSegment(
            value: 'teacher',
            label: Text('Teachers'),
          ),
        ],
        selected: {_selectedUserType},
        onSelectionChanged: (Set<String> selection) {
          setState(() {
            _selectedUserType = selection.first;
          });
        },
      ),
    );
  }


    
  

  Widget _buildUserCard({
    required BuildContext context,
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
    required bool isActive,
    required String role,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 4),
            Text(
              role,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserStatusSwitch(
              isActive: isActive,
              onChanged: (value) => setState(() => isActive = value),
            ),
            const SizedBox(width: 8),
            UserActionsMenu(
              userId: id,
              userName: name,
              userRole: role.toLowerCase(),
            ),
          ],
        ),
      ),
    );
  }
}