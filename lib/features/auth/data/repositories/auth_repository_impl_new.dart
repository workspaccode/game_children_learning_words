import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:readingquest_bilingual_learning/core/error/failures.dart';

import '../../domain/entities/register_params.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_type.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_storage.dart';
import '../models/user_model.dart';

abstract class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
    required LocalStorage localStorage,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn,
       _localStorage = localStorage;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final LocalStorage _localStorage;

  @override
  Future<User> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw Exception('No authenticated user found');
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data();
      final user = UserModel.fromJson({...userData, 'id': firebaseUser.uid});

      await _localStorage.saveUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(Failure('Authentication failed'));
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return const Left(Failure( 'User data not found'));
      }

      final user = UserModel.fromJson({
        ...userDoc.data()!,
        'id': credential.user!.uid,
      });

      await _localStorage.saveUser(user);
      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure( _mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(Failure( 'Authentication failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register(RegisterUserParams params) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      if (credential.user == null) {
        return const Left(Failure( 'Failed to create user'));
      }

      final user = UserModel(
        id: credential.user!.uid,
        email: params.email,
        name: params.name,
        role: params.userType == UserType.parent ? UserRole.parent : UserRole.child,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toJson());

      await _localStorage.saveUser(user);
      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure( _mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(Failure( 'Registration failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle({
    required UserType userType,
  }) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(Failure( 'Google sign in cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      if (userCredential.user == null) {
        return const Left(Failure( 'Failed to sign in with Google'));
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      User user;
      if (!userDoc.exists) {
        // Create new user profile
        user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName ?? '',
          role: userType.name == 'parent' ? UserRole.parent : UserRole.child,
          isActive: true,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set((user as UserModel).toJson());
      } else {
        user = UserModel.fromJson({
          ...userDoc.data()!,
          'id': userCredential.user!.uid,
        });
      }

      await _localStorage.saveUser(user);
      return Right(user);
    } catch (e) {
      return Left(Failure( 'Google sign in failed: ${e.toString()}'));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      _localStorage.deleteUser(),
    ]);
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        await signOut();
      }
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  @override
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) {
          await _localStorage.deleteUser();
          return null;
        }

        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          await _localStorage.deleteUser();
          return null;
        }

        final user = UserModel.fromJson({
          ...userDoc.data()!,
          'id': firebaseUser.uid,
        });

        await _localStorage.saveUser(user);
        return user;
      });

  String _mapFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-not-found':
        return 'No user found with this email';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'weak-password':
        return 'Please enter a stronger password';
      default:
        return e.message ?? 'An error occurred';
    }
  }

  @override
  Future<Either<Failure, bool>> checkParentExists(String parentEmail) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: parentEmail)
          .where('userType', isEqualTo: UserType.parent.name)
          .get();

      return Right(querySnapshot.docs.isNotEmpty);
    } catch (e) {
      return Left(Failure( 'Failed to check parent: ${e.toString()}'));
    }
  }
}
