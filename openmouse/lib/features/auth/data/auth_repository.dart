import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_client.dart';

class AuthRepository {
  SupabaseClient get _client => SupabaseClientService.client;

  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> sendOtp({required String email}) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );
  }

  Future<void> verifyOtp({required String email, required String token}) async {
    await _client.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: token,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
