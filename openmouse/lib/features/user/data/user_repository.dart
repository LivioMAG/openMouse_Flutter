import '../../../core/services/supabase_client.dart';
import '../../../models/profile.dart';

class UserRepository {
  Future<Profile?> getProfile(String userId) async {
    final data = await SupabaseClientService.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return Profile.fromMap(data);
  }

  Future<Profile> createProfile(String userId) async {
    final data = await SupabaseClientService.client
        .from('profiles')
        .insert({'id': userId, 'has_subscription': false})
        .select()
        .single();
    return Profile.fromMap(data);
  }
}
