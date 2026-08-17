import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../../data/services/auth_service.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthController extends ChangeNotifier {
  final AuthService _auth;
  StreamSubscription<AuthState>? _sub;

  AuthController(this._auth) {
    _status = _auth.currentUser == null
        ? AuthStatus.signedOut
        : AuthStatus.signedIn;
    _sub = _auth.authStateChanges.listen((event) {
      _status = event.session != null
          ? AuthStatus.signedIn
          : AuthStatus.signedOut;
      notifyListeners();
    });
  }

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;
  String? get email => _auth.currentUserEmail;
  String? get userId => _auth.currentUserId;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    await _auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
