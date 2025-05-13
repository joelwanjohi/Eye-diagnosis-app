import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opt_app/providers/displayname_provider.dart';
import 'package:opt_app/providers/email_provider.dart';
import 'package:opt_app/providers/firebase_provider.dart';
import 'package:opt_app/providers/firestore_provider.dart';
import 'package:opt_app/services/logger.dart';

class FirebaseService {
  FirebaseService(this.ref);
  final WidgetRef ref;

  // Sign up a new user
  Future<void> signUp(
    String displayname,
    String email,
    String password,
    String confirmPassword,
    void Function(Object error) onError,
    void Function(String success) onSuccess,
  ) async {
    try {
      if (displayname.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('Username, email, and password cannot be empty.');
      }
      if (password != confirmPassword) {
        throw Exception('Passwords do not match.');
      }

      // Create new Firebase User
      final UserCredential userCredential = await ref
          .read(firebaseProvider)
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store display name
      await userCredential.user?.updateDisplayName(displayname);

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Store user data in Firestore
      await ref
          .read(firestoreProvider)
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'displayName': displayname,
        'email': email,
        'creationDate': DateTime.now().toIso8601String(),
        'lastSignInDate': DateTime.now().toIso8601String(),
      });

      Logs.signupComplete();
      onSuccess('Successfully signed up! Please verify your email.');
    } catch (error) {
      Logs.signupFailed();
      onError(error);
      rethrow;
    }
  }

  // Log in an existing user
  Future<void> logIn(
    String email,
    String password,
    void Function(Object error) onError,
    void Function(String success) onSuccess,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty.');
      }

      // Sign in
      final UserCredential userCredential =
          await ref.read(firebaseProvider).signInWithEmailAndPassword(
                email: email,
                password: password,
              );

      final User? currentUser = userCredential.user;
      if (currentUser == null) {
        onError('Something went wrong. Please try again.');
      } else {
        if (!currentUser.emailVerified) {
          onError('Please verify your email address before logging in.');
        } else {
          // Fetch user data from Firestore
          final DocumentSnapshot<Map<String, dynamic>> doc = await ref
              .read(firestoreProvider)
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (doc.exists) {
            ref.read(displayNameProvider.notifier).state =
                doc['displayName'] as String;
            ref.read(emailProvider.notifier).state = doc['email'] as String;
          } else {
            Logs.loginFailed();
            onError('User data not found.');
            return;
          }

          Logs.loginComplete();
          onSuccess('Successfully logged in.');
        }
      }
    } catch (error) {
      Logs.loginFailed();
      onError(error);
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(
    String email,
    void Function(Object error) onError,
    void Function(String success) onSuccess,
  ) async {
    try {
      if (email.isEmpty) {
        throw Exception('Email cannot be empty.');
      }

      await ref.read(firebaseProvider).sendPasswordResetEmail(email: email);

      Logs.resetPasswordComplete();
      onSuccess('Password reset email sent.');
    } catch (error) {
      Logs.resetPasswordFailed();
      onError(error);
      rethrow;
    }
  }

  // Invalidate all providers
  void invalidateAllProviders() {
    ref
      ..invalidate(firebaseProvider)
      ..invalidate(firestoreProvider)
      ..invalidate(emailProvider);
  }
}
