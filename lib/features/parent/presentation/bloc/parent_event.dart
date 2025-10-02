part of 'parent_bloc.dart';

sealed class ParentEvent extends Equatable {
  const ParentEvent();

  @override
  List<Object?> get props => [];
}

class ParentLoadProfileEvent extends ParentEvent {

  const ParentLoadProfileEvent(this.parentId);
  final String parentId;

  @override
  List<Object> get props => [parentId];
}

class ParentUpdateProfileEvent extends ParentEvent {

  const ParentUpdateProfileEvent(this.parent);
  final ParentUser parent;

  @override
  List<Object> get props => [parent];
}

class ParentAddChildEvent extends ParentEvent {

  const ParentAddChildEvent({required this.parentId, required this.childId});
  final String parentId;
  final String childId;

  @override
  List<Object> get props => [parentId, childId];
}

class ParentRemoveChildEvent extends ParentEvent {

  const ParentRemoveChildEvent({required this.parentId, required this.childId});
  final String parentId;
  final String childId;

  @override
  List<Object> get props => [parentId, childId];
}

class ParentLoadChildrenEvent extends ParentEvent {

  const ParentLoadChildrenEvent(this.parentId);
  final String parentId;

  @override
  List<Object> get props => [parentId];
}

class ParentUpdatePaymentInfoEvent extends ParentEvent {

  const ParentUpdatePaymentInfoEvent({
    required this.parentId,
    required this.paymentInfo,
  });
  final String parentId;
  final Map<String, dynamic> paymentInfo;

  @override
  List<Object> get props => [parentId, paymentInfo];
}

class ParentWatchChildrenEvent extends ParentEvent {

  const ParentWatchChildrenEvent(this.parentId);
  final String parentId;

  @override
  List<Object> get props => [parentId];
}
