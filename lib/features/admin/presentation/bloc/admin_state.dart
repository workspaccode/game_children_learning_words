

part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminDashboardLoaded extends AdminState {

  const AdminDashboardLoaded(this.dashboardData);
  final Map<String, dynamic> dashboardData;

  @override
  List<Object> get props => [dashboardData];
}

class AdminUsersLoaded extends AdminState {

  const AdminUsersLoaded({
     required this.child,
    required this.parent,
    required this.teacher,
    required this.totalPages,
    required this.currentPage,
  
  });
  final ChildUserModel child;
  final ParentUserModel parent;
  final TeacherUserModel teacher;

  final int totalPages;
  final int currentPage;

  @override
  List<Object> get props => [child, parent, teacher, totalPages, currentPage];
}

class AdminSystemStatsLoaded extends AdminState {

  const AdminSystemStatsLoaded(this.stats);
  final Map<String, dynamic> stats;

  @override
  List<Object> get props => [stats];
}

class AdminReportGenerated extends AdminState {

  const AdminReportGenerated({
    required this.reportUrl,
    required this.generatedAt,
  });
  final String reportUrl;
  final DateTime generatedAt;

  @override
  List<Object> get props => [reportUrl, generatedAt];
}

class AdminSettingsUpdated extends AdminState {

  const AdminSettingsUpdated(this.settings);
  final Map<String, dynamic> settings;

  @override
  List<Object> get props => [settings];
}

class AdminContentManaged extends AdminState {

  const AdminContentManaged({
    required this.action,
    required this.contentId,
    required this.success,
  });
  final String action;
  final String contentId;
  final bool success;

  @override
  List<Object> get props => [action, contentId, success];
}

class AdminSystemStatus extends AdminState {

  const AdminSystemStatus({
    required this.isOnline,
    required this.metrics,
    required this.lastUpdated,
  });
  final bool isOnline;
  final Map<String, dynamic> metrics;
  final DateTime lastUpdated;

  @override
  List<Object> get props => [isOnline, metrics, lastUpdated];
}

class AdminError extends AdminState {

  const AdminError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}