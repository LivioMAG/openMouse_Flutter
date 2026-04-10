class FolderItem {
  const FolderItem({
    required this.id,
    required this.name,
    required this.userId,
    required this.workspaceId,
    required this.createdAt,
    this.parentId,
  });

  final String id;
  final String name;
  final String? parentId;
  final String userId;
  final String workspaceId;
  final DateTime createdAt;

  factory FolderItem.fromMap(Map<String, dynamic> map) {
    return FolderItem(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
      userId: map['user_id'] as String,
      workspaceId: map['arbeitsumgebung_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
