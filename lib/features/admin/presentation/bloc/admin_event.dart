

part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class AdminLoadDashboardEvent extends AdminEvent {
  const AdminLoadDashboardEvent();
}

class AdminLoadUsersEvent extends AdminEvent {

  const AdminLoadUsersEvent({
    required this.userType,
    this.page = 1,
    this.limit = 20,
  });
  final String userType;
  final int page;
  final int limit;

  @override
  List<Object> get props => [userType, page, limit];
}

class AdminUpdateUserStatusEvent extends AdminEvent {

  const AdminUpdateUserStatusEvent({
    required this.userId,
    required this.isActive,
  });
  final String userId;
  final bool isActive;

  @override
  List<Object> get props => [userId, isActive];
}

class AdminLoadSystemStatsEvent extends AdminEvent {
  const AdminLoadSystemStatsEvent();
}

class AdminGenerateReportEvent extends AdminEvent {

  const AdminGenerateReportEvent({
    required this.reportType,
    required this.startDate,
    required this.endDate,
  });
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [reportType, startDate, endDate];
}

class AdminUpdateSettingsEvent extends AdminEvent {

  const AdminUpdateSettingsEvent(this.settings);
  final Map<String, dynamic> settings;

  @override
  List<Object> get props => [settings];
}

class AdminManageContentEvent extends AdminEvent {

  const AdminManageContentEvent({
    required this.action,
    required this.contentId,
    this.data,
  });
  final String action;
  final String contentId;
  final Map<String, dynamic>? data;

  @override
  List<Object> get props => [action, contentId, if (data != null) data!];
}

class AdminWatchSystemStatusEvent extends AdminEvent {
  const AdminWatchSystemStatusEvent();
}

class AdminSystemStatusUpdatedEvent extends AdminEvent {

  const AdminSystemStatusUpdatedEvent(this.status);
  final Map<String, dynamic> status;

  @override
  List<Object> get props => [status];
}
class LoadUsersEvent extends AdminEvent {
  const LoadUsersEvent();
}

class UpdateUserEvent extends AdminEvent {

  const UpdateUserEvent({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}
class DeleteUserEvent extends AdminEvent {

  const DeleteUserEvent({required this.userId});
  final String userId;
  @override
  List<Object> get props => [userId];
}

class ResetUserPasswordEvent extends AdminEvent {

  const ResetUserPasswordEvent({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}