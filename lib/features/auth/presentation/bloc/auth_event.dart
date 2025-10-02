part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitializeEvent extends AuthEvent {
  const AuthInitializeEvent();
}

class AuthSignInWithEmailEvent extends AuthEvent {
  const AuthSignInWithEmailEvent({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  const AuthRegisterEvent(this.params);

  final RegisterUserParams params;

  @override
  List<Object> get props => [params];
}

class AuthSignInWithGoogleEvent extends AuthEvent {
  const AuthSignInWithGoogleEvent({required this.userType});

  final UserType userType;

  @override
  List<Object> get props => [userType];
}

class AuthSignOutEvent extends AuthEvent {
  const AuthSignOutEvent();
}

class AuthCheckConnectivityEvent extends AuthEvent {
  const AuthCheckConnectivityEvent({required this.isConnected});

  final bool isConnected;

  @override
  List<Object> get props => [isConnected];
}

class AuthCheckParentExistsEvent extends AuthEvent {
  const AuthCheckParentExistsEvent({required this.parentEmail});

  final String parentEmail;

  @override
  List<Object> get props => [parentEmail];
}
