import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/remote/supabase_client.dart';

/// Thin wrapper over Supabase auth. Exposes a stream of session changes
/// so the UI can react to login/logout without polling.
class AuthService {
  SupabaseClient get _client => SupabaseBootstrap.client;

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  String? get currentUserEmail => currentUser?.email;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
