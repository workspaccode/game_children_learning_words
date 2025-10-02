import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readingquest_bilingual_learning/features/child/data/models/child_user_model.dart';
import 'package:readingquest_bilingual_learning/features/parent/data/models/parent_user_model.dart';
import 'package:readingquest_bilingual_learning/features/teacher/data/models/teacher_user_model.dart';

import '../../domain/repositories/admin_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({required this.adminRepository}) : super(const AdminInitial()) {
    on<AdminLoadDashboardEvent>(_onLoadDashboard);
    on<AdminLoadUsersEvent>(_onLoadUsers);
    on<LoadUsersEvent>(_loadUsers);
    on<AdminUpdateUserStatusEvent>(_onUpdateUserStatus);
    on<AdminLoadSystemStatsEvent>(_onLoadSystemStats);
    on<AdminGenerateReportEvent>(_onGenerateReport);
    on<AdminUpdateSettingsEvent>(_onUpdateSettings);
    on<AdminManageContentEvent>(_onManageContent);
    on<AdminWatchSystemStatusEvent>(_onWatchSystemStatus);
  }
  final AdminRepository adminRepository;
  StreamSubscription? _systemStatusSubscription;

  Future<void> _onLoadDashboard(
    AdminLoadDashboardEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final result = await adminRepository.getDashboardData();
      result.fold(
        (failure) => emit(AdminError('$failure')),
        (data) => emit(AdminDashboardLoaded(data)),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadUsers(
    AdminLoadUsersEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final result = await adminRepository.getUsers(
        userType: event.userType,
        page: event.page,
        limit: event.limit,
      );
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (data) => emit(
          AdminUsersLoaded(
            child: ChildUserModel(
              id: 'child',
              name: 'Child User',
              email: 'child@example.com',
              age: 10,
              level: 1,
              parentId: 'parent',
              progress: {},
              isActive: true,
              createdAt: DateTime.now(),
            ),
            parent: ParentUserModel(
              id: 'parent',
              name: 'Parent User',
              email: 'parent@example.com',
              children: <String>[],
              isActive: true,
              createdAt: DateTime.now(),
            ),
            teacher: TeacherUserModel(
              id: 'teacher',
              name: 'Teacher User',
              email: 'teacher@example.com',
              studentIds: <String>[],
              schoolName: 'School',
              subjects: ['English'],
              qualification: 'Bachelor',
              isActive: true,
              createdAt: DateTime.now(),
            ),
            totalPages: 1,
            currentPage: 1,
          ),
        ),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
  Future<void> _loadUsers(
    LoadUsersEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final result = await adminRepository.getUsers(
        userType: 'all',
        page: 1,
        limit: 100,
      );
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (data) => emit(
          AdminUsersLoaded(
            child: ChildUserModel(
              id: 'child',
              name: 'Child User',
              email: 'child@example.com',
              age: 10,
              level: 1,
              parentId: 'parent',
              progress: {},
              isActive: true,
              createdAt: DateTime.now(),
            ),
            parent: ParentUserModel(
              id: 'parent',
              name: 'Parent User',
              email: 'parent@example.com',
              children: <String>[],
              isActive: true,
              createdAt: DateTime.now(),
            ),
            teacher: TeacherUserModel(
              id: 'teacher',
              name: 'Teacher User',
              email: 'teacher@example.com',
              studentIds: <String>[],
              schoolName: 'School',
              subjects: ['English'],
              qualification: 'Bachelor',
              isActive: true,
              createdAt: DateTime.now(),
            ),
            totalPages: 1,
            currentPage: 1,
          ),
        ),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUpdateUserStatus(
    AdminUpdateUserStatusEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final result = await adminRepository.updateUserStatus(
        userId: event.userId,
        isActive: event.isActive,
      );
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (_) => add(const AdminLoadUsersEvent(userType: 'all')),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadSystemStats(
    AdminLoadSystemStatsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final result = await adminRepository.getSystemStats();
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (stats) => emit(AdminSystemStatsLoaded(stats)),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onGenerateReport(
    AdminGenerateReportEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final result = await adminRepository.generateReport(event.reportType);
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (success) => emit(
          AdminReportGenerated(
            reportUrl: 'Report generated successfully',
            generatedAt: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    AdminUpdateSettingsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final result = await adminRepository.updateSettings(event.settings);
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (settings) => emit(AdminSettingsUpdated(event.settings)),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onManageContent(
    AdminManageContentEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final result = await adminRepository.manageContent({
        'action': event.action,
        'contentId': event.contentId,
        'data': event.data,
      });
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (_) => emit(
          AdminContentManaged(
            action: event.action,
            contentId: event.contentId,
            success: true,
          ),
        ),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  void _onWatchSystemStatus(
    AdminWatchSystemStatusEvent event,
    Emitter<AdminState> emit,
  ) {
    _systemStatusSubscription?.cancel();
    _systemStatusSubscription = adminRepository.watchSystemStatus().listen(
      (status) => emit(
        AdminSystemStatus(
          isOnline: status['isOnline'] as bool,
          metrics: status['metrics'] as Map<String, dynamic>,
          lastUpdated: DateTime.now(),
        ),
      ),
      onError: (error) => emit(AdminError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _systemStatusSubscription?.cancel();
    return super.close();
  }
}
