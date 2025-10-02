import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readingquest_bilingual_learning/features/child/data/models/child_user_model.dart';
import 'package:readingquest_bilingual_learning/features/parent/data/models/parent_user_model.dart';
import 'package:readingquest_bilingual_learning/features/teacher/data/models/teacher_user_model.dart';

import 'user_actions_menu.dart';
import 'user_card.dart';
import 'user_status_switch.dart';

class UserGridView extends StatelessWidget {
  const UserGridView({
    super.key,

    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onUserStatusChanged,
    required this.childModel,
    required this.parentModel,
    required this.teasherModel,
  });
  final List<ChildUserModel> childModel;
  final List<ParentUserModel> parentModel;
  final List<TeacherUserModel> teasherModel;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final Function(String, bool) onUserStatusChanged;

  @override
  Widget build(BuildContext context) {
    bool isChildPage = childModel.isNotEmpty;
    bool isParentPage = parentModel.isNotEmpty;
    bool isTeacherPage = teasherModel.isNotEmpty;
   // List users = [];
    // if (isChildPage) {
    //   users = childModel;
    // } else if (isParentPage) {
    //   users = parentModel;
    // } else {
    //   users = teasherModel;
    // }
    return 
    
    
    Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: currentPage > 1
                  ? () => onPageChanged(currentPage - 1)
                  : null,
            ),
            Text('Page $currentPage of $totalPages'),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: childModel.length,
            itemBuilder: (context, index) {
              return UserCard(
                name: childModel[index].name,
                email: childModel[index].email,
                status: childModel[index].isActive ? 'Active' : 'Inactive',
      // user: users[index],
                // onUserStatusChanged: onUserStatusChanged,
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: parentModel.length,
            itemBuilder: (context, index) {
              return UserCard(
                name: parentModel[index].name,
                email: parentModel[index].email,
                status: parentModel[index].isActive ? 'Active' : 'Inactive',
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: teasherModel.length,
            itemBuilder: (context, index) {
              return UserCard(
                name: teasherModel[index].name,
                email: teasherModel[index].email,
                status: teasherModel[index].isActive ? 'Active' : 'Inactive',
              );
            },
          ),
        ),
      ],
    );
  }
}

class ChildUserCard extends StatelessWidget {
  const ChildUserCard({
    super.key,
    required this.user,
    required this.onUserStatusChanged,
  });

  final ChildUserModel user;
  // ignore: inference_failure_on_function_return_type
  final Function(User user, bool isBlocked) onUserStatusChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector();
  }
}
class ParentUserCard extends StatelessWidget {
  const ParentUserCard({
    super.key,
    required this.user,
    required this.onUserStatusChanged,
  });

  final ParentUserModel user;
  // ignore: inference_failure_on_function_return_type
  final Function(User user, bool isBlocked) onUserStatusChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector();
  }
}
class TeasherUserCard extends StatelessWidget {
  const TeasherUserCard({
    super.key,
    required this.user,
    required this.onUserStatusChanged,
  });

  final TeacherUserModel user;
  // ignore: inference_failure_on_function_return_type
  final Function(User user, bool isBlocked) onUserStatusChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector();
  }
}

class UserStatusSwitch extends StatelessWidget {

  const UserStatusSwitch({
    super.key,
    required this.isBlocked,
    required this.onChanged,
  });
  final bool isBlocked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isBlocked,
      onChanged: onChanged,
      activeThumbColor: Colors.red,
      activeTrackColor: Colors.redAccent,
      inactiveThumbColor: Colors.green,
      inactiveTrackColor: Colors.greenAccent,
    );
  }
}
