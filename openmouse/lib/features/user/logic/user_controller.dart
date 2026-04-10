import 'package:flutter/foundation.dart';

import '../../../core/services/supabase_client.dart';
import '../../../models/profile.dart';
import '../data/user_repository.dart';

class UserController extends ChangeNotifier {
  UserController(this._repository);

  final UserRepository _repository;
  Profile? profile;
  bool loading = false;
  String? error;

  bool get hasSubscription => profile?.hasSubscription ?? false;

  Future<void> loadOrCreateProfile() async {
    final user = SupabaseClientService.client.auth.currentUser;
    if (user == null) return;

    loading = true;
    error = null;
    notifyListeners();
    try {
      debugPrint('Loading profile for user: ${user.id}');
      profile = await _repository.getProfile(user.id);
      if (profile == null) {
        debugPrint('No profile found. Creating one for user: ${user.id}');
        profile = await _repository.createProfile(user.id);
      }
      debugPrint(
        'Profile loaded. has_subscription=${profile?.hasSubscription} user=${profile?.id}',
      );
    } catch (e) {
      error = e.toString();
      debugPrint('Profile load failed: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clear() {
    profile = null;
    error = null;
    notifyListeners();
  }
}
