import 'package:flutter/foundation.dart';

import '../../../core/services/supabase_client.dart';
import '../../../models/workspace.dart';
import '../../user/logic/user_controller.dart';
import '../data/workspace_repository.dart';

class WorkspaceController extends ChangeNotifier {
  WorkspaceController(this._repository, this._userController);

  final WorkspaceRepository _repository;
  final UserController _userController;

  List<Workspace> workspaces = [];
  bool loading = false;
  String? error;

  Future<void> loadWorkspaces() async {
    final user = SupabaseClientService.client.auth.currentUser;
    if (user == null) return;

    loading = true;
    error = null;
    notifyListeners();
    try {
      workspaces = await _repository.fetchWorkspaces(user.id);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> createWorkspace({
    required String projektname,
    required String kommissionsnummer,
  }) async {
    final user = SupabaseClientService.client.auth.currentUser;
    if (user == null) return false;
    if (!_userController.hasSubscription) {
      error = 'Kein aktives Abo. Arbeitsumgebung kann nicht erstellt werden.';
      notifyListeners();
      return false;
    }
    if (projektname.trim().isEmpty || kommissionsnummer.trim().isEmpty) {
      error = 'Projektname und Kommissionsnummer sind Pflichtfelder.';
      notifyListeners();
      return false;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      await _repository.createWorkspace(
        userId: user.id,
        projektname: projektname,
        kommissionsnummer: kommissionsnummer,
      );
      await loadWorkspaces();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
