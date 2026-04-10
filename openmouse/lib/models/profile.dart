class Profile {
  const Profile({required this.id, required this.hasSubscription});

  final String id;
  final bool hasSubscription;

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      hasSubscription: map['has_subscription'] as bool? ?? false,
    );
  }
}
