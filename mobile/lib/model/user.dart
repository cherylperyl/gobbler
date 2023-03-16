class User {
  const User({
    required this.userId,
    required this.isPremium,
    required this.username,
    required this.dateCreated,
    required this.lastUpdated,
    required this.email,
  });

  final int userId;
  final bool isPremium;
  final String username;
  final DateTime dateCreated;
  final DateTime? lastUpdated;
  final String email;
  // String get assetName => '$id-0.jpg';
  // String get assetPackage => 'shrine_images';

  // @override
  // String toString() => '$name (id=$id)';
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      isPremium: json['isPremium'],
      username: json['username'],
      dateCreated: DateTime.parse(json['dateCreated']),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      email: json['email']
    );
  }
  @override
  String toString() {
    return "{userId: $userId, email: $email, isPremium: $isPremium, }";
  }
}