import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readingquest_bilingual_learning/features/admin/presentation/widgets/error_view.dart';
import 'package:readingquest_bilingual_learning/features/admin/presentation/widgets/loading_view.dart';

import '../bloc/admin_bloc.dart';
import '../widgets/user_filter_bar.dart';
import '../widgets/user_grid_view.dart';
import '../widgets/user_list_view.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedUserType = 'all';
  bool _isGridView = false;
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    context.read<AdminBloc>().add(
      AdminLoadUsersEvent(
        userType: _selectedUserType,
        page: _currentPage,
        limit: _itemsPerPage,
      ),
    );
  }

  void _onUserTypeChanged(String type) {
    setState(() {
      _selectedUserType = type;
      _currentPage = 1;
    });
    _loadUsers();
  }

  void _onViewTypeChanged(bool isGrid) {
    setState(() {
      _isGridView = isGrid;
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadUsers();
  }

  void _onSearch(String query) {
    // Implement search functionality
  }

  void _onUserStatusChanged(String userId, bool isActive) {
    context.read<AdminBloc>().add(
      AdminUpdateUserStatusEvent(userId: userId, isActive: isActive),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => _onViewTypeChanged(!_isGridView),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: Column(
        children: [
          UserFilterBar(
            selectedType: _selectedUserType,
            onTypeChanged: _onUserTypeChanged,
            searchController: _searchController,
            onSearch: _onSearch,
          ),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const LoadingView();
                }

                if (state is AdminError) {
                  return ErrorViewWithMessage(
                    message: state.message,
                    onRetry: _loadUsers,
                  );
                }

                if (state is AdminUsersLoaded) {
                  final child = state.child;
                  final parent = state.parent;
                  final teacher = state.teacher;
                  final totalPages = state.totalPages;

                  if (_isGridView) {
                    return UserGridView(
                      //users: users,
                      currentPage: _currentPage,
                      totalPages: totalPages,
                      onPageChanged: _onPageChanged,
                      onUserStatusChanged: _onUserStatusChanged,
                      childModel: [child],
                      parentModel: [parent],
                      teasherModel: [teacher],
                    );
                  }

                  return const UserListView();
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to user creation screen
          Navigator.pushNamed(context, '/admin/users/create');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
