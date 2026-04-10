import '../../../core/services/supabase_client.dart';
import '../../../models/workspace.dart';

class WorkspaceRepository {
  Future<List<Workspace>> fetchWorkspaces(String userId) async {
    final rows = await SupabaseClientService.client
        .from('arbeitsumgebungen')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows
        .map<Workspace>((row) => Workspace.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> createWorkspace({
    required String userId,
    required String projektname,
    required String kommissionsnummer,
  }) async {
    await SupabaseClientService.client.from('arbeitsumgebungen').insert({
      'user_id': userId,
      'projektname': projektname,
      'kommissionsnummer': kommissionsnummer,
    });
  }
}
