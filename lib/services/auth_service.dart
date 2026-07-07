import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// A Firebase-backed auth service that handles registration, login, and sessions.
class AuthService {
  // ── Singleton ────────────────────────────────────────────────────────────
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns `null` on success, or an error message string.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException(
          'Connection timed out. Please check your internet connection '
          'and try again.'
        );
      });

      // Save user's display name
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name.trim()).timeout(const Duration(seconds: 5));
        // Force reload the user to apply updates locally
        await credential.user!.reload().timeout(const Duration(seconds: 5));
      }
      return null; // success
    } on TimeoutException catch (e) {
      return e.message;
    } on FirebaseAuthException catch (e) {
      debugPrint("Auth register error code: ${e.code}");
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak. Please use a stronger password.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled in Firebase. Please enable them in console.';
        default:
          return e.message ?? 'An unknown error occurred during sign up.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns `null` on success, or an error message string.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException(
          'Connection timed out. Please check your internet connection '
          'and try again.'
        );
      });
      return null; // success
    } on TimeoutException catch (e) {
      return e.message;
    } on FirebaseAuthException catch (e) {
      debugPrint("Auth login error code: ${e.code}");
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
          return 'This email is not registered, or the password is incorrect. Please sign up or check your credentials.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'An unknown error occurred during sign in.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns the logged-in user map, or null if not logged in.
  Future<Map<String, dynamic>?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return {
      'uid': user.uid,
      'name': user.displayName ?? 'Stellar Explorer',
      'email': user.email ?? '',
    };
  }

  /// Returns true if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  /// Logs out the current user.
  Future<void> logout() async {
    await _auth.signOut();
  }
}
