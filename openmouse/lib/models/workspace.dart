class Workspace {
  const Workspace({
    required this.id,
    required this.userId,
    required this.projektname,
    required this.kommissionsnummer,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String projektname;
  final String kommissionsnummer;
  final DateTime createdAt;

  factory Workspace.fromMap(Map<String, dynamic> map) {
    return Workspace(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      projektname: map['projektname'] as String,
      kommissionsnummer: map['kommissionsnummer'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
