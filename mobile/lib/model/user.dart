import 'package:intl/intl.dart';

class User {
  User({
    required this.userId,
    required this.isPremium,
    required this.username,
    required this.dateCreated,
    required this.lastUpdated,
    required this.email,
    required this.stripeId,
    required this.subscriptionId,
  });

  final int userId;
  bool isPremium;
  final String username;
  final DateTime dateCreated;
  final DateTime? lastUpdated;
  final String email;
  final String? stripeId;
  final String? subscriptionId;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      isPremium: json['isPremium'],
      username: json['username'],
      dateCreated: DateTime.parse(json['dateCreated']),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      email: json['email'],
      stripeId: json['stripeId'],
      subscriptionId: json['subscriptionId']
    );
  }
  @override
  String toString() {
    return "{userId: $userId, email: $email, isPremium: $isPremium, dateCreated: $dateCreated, lastUpdated: $lastUpdated, username: $username, stripeId: $stripeId, subscriptionId: $subscriptionId}";
  }
  Map toJson() {
    return {
      'userId': userId,
      'isPremium': isPremium,
      'username': username,
      'dateCreated': DateFormat().format(dateCreated),
      'lastUpdated': lastUpdated != null ? DateFormat().format(lastUpdated!) : null,
      'email': email,
      'stripeId': stripeId,
      'subscriptionId': subscriptionId
    };
  }
}