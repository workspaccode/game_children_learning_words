part of 'parent_bloc.dart';

sealed class ParentState extends Equatable {
  const ParentState();

  @override
  List<Object?> get props => [];
}

class ParentInitial extends ParentState {
  const ParentInitial();
}

class ParentLoading extends ParentState {
  const ParentLoading();
}

class ParentLoaded extends ParentState {

  const ParentLoaded(this.parent);
  final ParentUser parent;

  @override
  List<Object> get props => [parent];
}

class ParentChildrenLoaded extends ParentState {

  const ParentChildrenLoaded(this.children);
  final List<ChildUser> children;

  @override
  List<Object> get props => [children];
}

class ParentPaymentInfoUpdated extends ParentState {

  const ParentPaymentInfoUpdated(this.paymentInfo);
  final Map<String, dynamic> paymentInfo;

  @override
  List<Object> get props => [paymentInfo];
}

class ParentError extends ParentState {

  const ParentError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
