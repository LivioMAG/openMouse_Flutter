import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../user/logic/user_controller.dart';
import '../data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authRepository, this._userController) {
    _subscription =
        _authRepository.authStateChanges.listen((_) => notifyListeners());
  }

  final AuthRepository _authRepository;
  final UserController _userController;
  late final StreamSubscription<AuthState> _subscription;

  bool isLoading = false;
  String? error;

  User? get currentUser => _authRepository.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<void> signUp(String email, String password) async {
    await _run(() async {
      await _authRepository.signUp(email: email, password: password);
    });
  }

  Future<void> signIn(String email, String password) async {
    await _run(() async {
      await _authRepository.signIn(email: email, password: password);
      await _userController.loadOrCreateProfile();
    });
  }

  Future<void> sendOtp(String email) async {
    await _run(() async {
      await _authRepository.sendOtp(email: email);
    });
  }

  Future<void> verifyOtp(String email, String token) async {
    await _run(() async {
      await _authRepository.verifyOtp(email: email, token: token);
      await _userController.loadOrCreateProfile();
    });
  }

  Future<void> signOut() async {
    await _run(() async {
      await _authRepository.signOut();
      _userController.clear();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } on AuthException catch (e) {
      error = e.message;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
