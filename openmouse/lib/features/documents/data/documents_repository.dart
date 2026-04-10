import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_client.dart';
import '../../../models/file_item.dart';
import '../../../models/folder.dart';

class DocumentsRepository {
  DocumentsRepository(this.storageBucket);

  final String storageBucket;

  SupabaseClient get _client => SupabaseClientService.client;

  Future<List<FolderItem>> fetchFolders({
    required String userId,
    required String workspaceId,
    String? parentId,
  }) async {
    final query = _client
        .from('folders')
        .select()
        .eq('user_id', userId)
        .eq('arbeitsumgebung_id', workspaceId);

    final rows = parentId == null
        ? await query.isFilter('parent_id', null)
        : await query.eq('parent_id', parentId);

    return rows
        .map<FolderItem>((row) => FolderItem.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<FileItem>> fetchFiles({
    required String userId,
    required String workspaceId,
    String? folderId,
  }) async {
    final query = _client
        .from('files')
        .select()
        .eq('user_id', userId)
        .eq('arbeitsumgebung_id', workspaceId);

    final rows = folderId == null
        ? await query.isFilter('folder_id', null)
        : await query.eq('folder_id', folderId);

    return rows
        .map<FileItem>((row) => FileItem.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> createFolder({
    required String name,
    required String userId,
    required String workspaceId,
    String? parentId,
  }) async {
    await _client.from('folders').insert({
      'name': name,
      'parent_id': parentId,
      'user_id': userId,
      'arbeitsumgebung_id': workspaceId,
    });
  }

  Future<void> renameFolder({required String folderId, required String name}) async {
    await _client.from('folders').update({'name': name}).eq('id', folderId);
  }

  Future<void> renameFile({required String fileId, required String name}) async {
    await _client.from('files').update({'name': name}).eq('id', fileId);
  }

  Future<void> uploadFile({
    required String userId,
    required String workspaceId,
    required String fileName,
    required Uint8List bytes,
    required int sizeBytes,
    String? folderId,
  }) async {
    final safeName = fileName.replaceAll(' ', '_');
    final path = '$userId/$workspaceId/${folderId ?? 'root'}/$safeName';

    await _client.storage.from(storageBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    await _client.from('files').insert({
      'name': fileName,
      'file_path': path,
      'folder_id': folderId,
      'user_id': userId,
      'arbeitsumgebung_id': workspaceId,
      'size_bytes': sizeBytes,
    });
  }

  Future<String> createSignedUrl(String path) {
    return _client.storage.from(storageBucket).createSignedUrl(path, 60);
  }

  Future<void> deleteFile(FileItem file) async {
    await _client.storage.from(storageBucket).remove([file.filePath]);
    await _client.from('files').delete().eq('id', file.id);
  }

  Future<void> deleteFolderRecursive({
    required FolderItem folder,
    required String userId,
    required String workspaceId,
  }) async {
    final childFolders = await _client
        .from('folders')
        .select()
        .eq('user_id', userId)
        .eq('arbeitsumgebung_id', workspaceId)
        .eq('parent_id', folder.id);

    for (final child in childFolders.map<FolderItem>(
      (row) => FolderItem.fromMap(row as Map<String, dynamic>),
    )) {
      await deleteFolderRecursive(
        folder: child,
        userId: userId,
        workspaceId: workspaceId,
      );
    }

    final filesInFolder = await _client
        .from('files')
        .select()
        .eq('user_id', userId)
        .eq('arbeitsumgebung_id', workspaceId)
        .eq('folder_id', folder.id);

    final paths = filesInFolder
        .map((e) => (e as Map<String, dynamic>)['file_path'] as String)
        .toList();

    if (paths.isNotEmpty) {
      await _client.storage.from(storageBucket).remove(paths);
    }

    await _client.from('files').delete().eq('folder_id', folder.id);
    await _client.from('folders').delete().eq('id', folder.id);
  }
}
