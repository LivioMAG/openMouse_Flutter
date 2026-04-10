import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../models/file_item.dart';
import '../../../models/folder.dart';
import '../data/documents_repository.dart';
import '../logic/documents_controller.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final config = context.read<AppConfig>();
    return ChangeNotifierProvider(
      create: (_) => DocumentsController(
        DocumentsRepository(config.storageBucket),
        workspaceId,
      )..loadCurrentLevel(),
      child: const _DocumentsView(),
    );
  }
}

class _DocumentsView extends StatelessWidget {
  const _DocumentsView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DocumentsController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: CupertinoSearchTextField(
                  onChanged: ctrl.setSearch,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _createFolder(context),
                icon: const Icon(CupertinoIcons.folder_badge_plus),
              ),
              IconButton(
                onPressed: () => _pickAndUpload(context),
                icon: const Icon(CupertinoIcons.cloud_upload),
              ),
            ],
          ),
        ),
        if (ctrl.breadcrumbs.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TextButton(
                  onPressed: ctrl.goRoot,
                  child: const Text('Root'),
                ),
                ...ctrl.breadcrumbs.asMap().entries.map(
                  (entry) => TextButton(
                    onPressed: () => ctrl.openBreadcrumb(entry.key),
                    child: Text('/ ${entry.value.name}'),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3,
            padding: const EdgeInsets.all(12),
            children: [
              ...ctrl.filteredFolders.map(
                (folder) => Card(
                  child: ListTile(
                    leading: const Icon(CupertinoIcons.folder_fill),
                    title: Text(folder.name),
                    onTap: () => ctrl.openFolder(folder),
                    onLongPress: () => _folderMenu(context, folder),
                  ),
                ),
              ),
              ...ctrl.filteredFiles.map(
                (file) => Card(
                  child: ListTile(
                    leading: const Icon(CupertinoIcons.doc_fill),
                    title: Text(file.name),
                    onTap: () async {
                      final url = await ctrl.signedUrl(file);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Signed URL: $url')),
                        );
                      }
                    },
                    onLongPress: () => _fileMenu(context, file.id, file.name, file),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createFolder(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final create = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Ordner erstellen'),
        content: CupertinoTextField(controller: nameCtrl, placeholder: 'Name'),
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
      await context.read<DocumentsController>().createFolder(nameCtrl.text.trim());
    }
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    final file = result?.files.first;
    if (file?.bytes != null && context.mounted) {
      await context.read<DocumentsController>().uploadFile(file!.name, file.bytes!);
    }
  }

  Future<void> _folderMenu(BuildContext context, FolderItem folder) async {
    final ctrl = context.read<DocumentsController>();
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: const Text('Umbenennen'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              title: const Text('Löschen (rekursiv)'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'rename' && context.mounted) {
      final c = TextEditingController(text: folder.name);
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Ordner umbenennen'),
          content: TextField(controller: c),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Speichern')),
          ],
        ),
      );
      if (ok == true) await ctrl.renameFolder(folder.id, c.text.trim());
    }
    if (action == 'delete') {
      await ctrl.deleteFolder(folder);
    }
  }

  Future<void> _fileMenu(
    BuildContext context,
    String fileId,
    String fileName,
    FileItem file,
  ) async {
    final ctrl = context.read<DocumentsController>();
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: const Text('Umbenennen'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              title: const Text('Löschen'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'rename' && context.mounted) {
      final c = TextEditingController(text: fileName);
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Datei umbenennen'),
          content: TextField(controller: c),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Speichern')),
          ],
        ),
      );
      if (ok == true) await ctrl.renameFile(fileId, c.text.trim());
    }
    if (action == 'delete') {
      await ctrl.deleteFile(file);
    }
  }
}
