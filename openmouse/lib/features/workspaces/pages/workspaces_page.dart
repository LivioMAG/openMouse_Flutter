import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/logic/auth_controller.dart';
import '../../user/pages/profile_page.dart';
import '../logic/workspace_controller.dart';
import 'workspace_detail_page.dart';

class WorkspacesPage extends StatefulWidget {
  const WorkspacesPage({super.key});

  @override
  State<WorkspacesPage> createState() => _WorkspacesPageState();
}

class _WorkspacesPageState extends State<WorkspacesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkspaceController>().loadWorkspaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspaceController = context.watch<WorkspaceController>();
    final authController = context.read<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arbeitsumgebungen'),
        actions: [
          IconButton(
            onPressed: () => authController.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createWorkspace(context),
        icon: const Icon(Icons.add),
        label: const Text('Arbeitsumgebung erstellen'),
      ),
      body: RefreshIndicator(
        onRefresh: workspaceController.loadWorkspaces,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ProfilePage(),
            const SizedBox(height: 12),
            if (workspaceController.error != null)
              Text(
                workspaceController.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ...workspaceController.workspaces.map(
              (workspace) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  title: Text(workspace.projektname),
                  subtitle: Text('KN: ${workspace.kommissionsnummer}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WorkspaceDetailPage(workspace: workspace),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createWorkspace(BuildContext context) async {
    final projektCtrl = TextEditingController();
    final komCtrl = TextEditingController();

    final create = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Neue Arbeitsumgebung'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            CupertinoTextField(controller: projektCtrl, placeholder: 'Projektname'),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: komCtrl,
              placeholder: 'Kommissionsnummer',
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );

    if (create == true && context.mounted) {
      final ok = await context.read<WorkspaceController>().createWorkspace(
            projektname: projektCtrl.text.trim(),
            kommissionsnummer: komCtrl.text.trim(),
          );
      if (!ok && context.mounted) {
        final err = context.read<WorkspaceController>().error ?? 'Unbekannter Fehler';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }
}
