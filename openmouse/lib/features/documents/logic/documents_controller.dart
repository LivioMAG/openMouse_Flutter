import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../../core/services/supabase_client.dart';
import '../../../models/file_item.dart';
import '../../../models/folder.dart';
import '../data/documents_repository.dart';

class DocumentsController extends ChangeNotifier {
  DocumentsController(this._repository, this.workspaceId);

  final DocumentsRepository _repository;
  final String workspaceId;

  String? currentFolderId;
  List<FolderItem> breadcrumbs = [];
  List<FolderItem> folders = [];
  List<FileItem> files = [];
  String search = '';
  bool loading = false;
  String? error;

  String get _userId => SupabaseClientService.client.auth.currentUser!.id;

  List<FolderItem> get filteredFolders {
    if (search.isEmpty) return folders;
    return folders
        .where((f) => f.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  List<FileItem> get filteredFiles {
    if (search.isEmpty) return files;
    return files
        .where((f) => f.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  Future<void> loadCurrentLevel() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      folders = await _repository.fetchFolders(
        userId: _userId,
        workspaceId: workspaceId,
        parentId: currentFolderId,
      );
      files = await _repository.fetchFiles(
        userId: _userId,
        workspaceId: workspaceId,
        folderId: currentFolderId,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createFolder(String name) async {
    await _repository.createFolder(
      name: name,
      userId: _userId,
      workspaceId: workspaceId,
      parentId: currentFolderId,
    );
    await loadCurrentLevel();
  }

  Future<void> renameFolder(String folderId, String name) async {
    await _repository.renameFolder(folderId: folderId, name: name);
    await loadCurrentLevel();
  }

  Future<void> renameFile(String fileId, String name) async {
    await _repository.renameFile(fileId: fileId, name: name);
    await loadCurrentLevel();
  }

  Future<void> uploadFile(String fileName, Uint8List bytes) async {
    await _repository.uploadFile(
      userId: _userId,
      workspaceId: workspaceId,
      fileName: fileName,
      bytes: bytes,
      sizeBytes: bytes.length,
      folderId: currentFolderId,
    );
    await loadCurrentLevel();
  }

  Future<void> deleteFile(FileItem file) async {
    await _repository.deleteFile(file);
    await loadCurrentLevel();
  }

  Future<void> deleteFolder(FolderItem folder) async {
    await _repository.deleteFolderRecursive(
      folder: folder,
      userId: _userId,
      workspaceId: workspaceId,
    );
    await loadCurrentLevel();
  }

  Future<String> signedUrl(FileItem file) =>
      _repository.createSignedUrl(file.filePath);

  Future<void> openFolder(FolderItem folder) async {
    breadcrumbs = [...breadcrumbs, folder];
    currentFolderId = folder.id;
    await loadCurrentLevel();
  }

  Future<void> openBreadcrumb(int index) async {
    breadcrumbs = breadcrumbs.sublist(0, index + 1);
    currentFolderId = breadcrumbs.last.id;
    await loadCurrentLevel();
  }

  Future<void> goRoot() async {
    breadcrumbs = [];
    currentFolderId = null;
    await loadCurrentLevel();
  }
}
