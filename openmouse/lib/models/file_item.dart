class FileItem {
  const FileItem({
    required this.id,
    required this.name,
    required this.filePath,
    required this.userId,
    required this.workspaceId,
    required this.createdAt,
    this.folderId,
    this.sizeBytes,
  });

  final String id;
  final String name;
  final String filePath;
  final String? folderId;
  final String userId;
  final String workspaceId;
  final int? sizeBytes;
  final DateTime createdAt;

  factory FileItem.fromMap(Map<String, dynamic> map) {
    return FileItem(
      id: map['id'] as String,
      name: map['name'] as String,
      filePath: map['file_path'] as String,
      folderId: map['folder_id'] as String?,
      userId: map['user_id'] as String,
      workspaceId: map['arbeitsumgebung_id'] as String,
      sizeBytes: map['size_bytes'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
