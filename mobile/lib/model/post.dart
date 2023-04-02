// enum Category {
//   all,
//   accessories,
//   clothing,
//   home,
// }

class Post {
  Post({
    required this.userId,
    required this.postId,
    required this.title,
    required this.imageUrl,
    required this.locationDescription,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.availableReservations,
    required this.totalReservations,
    required this.createdAt,
    required this.timeEnd,
    required this.isAvailable,
    this.distance,
    this.updatedAt,
  });

  final num userId;
  final num postId;
  final String title;
  final String imageUrl;
  final String locationDescription;
  final num locationLatitude;
  final num locationLongitude;
  num availableReservations;
  final num totalReservations;
  final DateTime createdAt;
  final DateTime timeEnd;
  final bool isAvailable;
  final DateTime? updatedAt;
  final num? distance;

  num get reservations => availableReservations;
  String get imageLink => imageUrl;
  String get postTitle => title;
  // String get assetName => '$id-0.jpg';
  // String get assetPackage => 'shrine_images';

  // @override
  // String toString() => '$name (id=$id)';
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['user_id'],
      postId: json['post_id'],
      title: json['title'],
      imageUrl: json['image_url'],
      locationDescription: json['location_description'],
      locationLatitude: json['location_latitude'],
      locationLongitude: json['location_longitude'],
      availableReservations: json['available_reservations'],
      totalReservations: json['total_reservations'],
      createdAt: DateTime.parse(json['created_at']),
      timeEnd: DateTime.parse(json['time_end']),
      isAvailable: json['is_available'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      distance: json['distance']
    );
  }
}