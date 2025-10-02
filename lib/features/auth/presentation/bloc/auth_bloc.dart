import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/register_params.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_type.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepository,
    required this.connectivity,
  }) : super(const AuthInitial()) {
    on<AuthInitializeEvent>(_onInitialize);
    on<AuthSignInWithEmailEvent>(_onSignInWithEmail);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthSignInWithGoogleEvent>(_onSignInWithGoogle);
    on<AuthSignOutEvent>(_onSignOut);
    on<AuthCheckParentExistsEvent>(_onCheckParentExists);

    _setupConnectivityListener();
  }

  final AuthRepository authRepository;
  final Connectivity connectivity;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  Future<void> _setupConnectivityListener() async {
    // Check initial connectivity state
    final status = await connectivity.checkConnectivity();
    if (status == ConnectivityResult.none) {
      emit(const AuthNetworkDisconnected());
    }

    // Listen for connectivity changes
     connectivity.onConnectivityChanged.listen((List<ConnectivityResult> statuses) {
      if (status == ConnectivityResult.none) {
        emit(const AuthNetworkDisconnected());
      }
    });
  }

  Future<void> _onInitialize(
    AuthInitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Failed to initialize: ${e.toString()}'));
    }
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Sign in failed: ${e.toString()}'));
    }
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await authRepository.register(event.params);

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await authRepository.signInWithGoogle(userType: event.userType);

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Google sign in failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Sign out failed: ${e.toString()}'));
    }
  }

  Future<void> _onCheckParentExists(
    AuthCheckParentExistsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCheckingParent());
    try {
      final result = await authRepository.checkParentExists(event.parentEmail);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (exists) => exists
            ? emit(const AuthParentExists())
            : emit(const AuthParentDoesNotExist()),
      );
    } catch (e) {
      emit(AuthError('Parent check failed: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

}
