import 'dart:convert';
import 'dart:ffi';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post.dart';
import 'package:http/http.dart' as http;

class PostRepository {
  static Future<List<Post>> fetchPosts() async {
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}:5001",'/posts');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final dataList = jsonDecode(response.body);
      List<Post> results = [];
      dataList.forEach((el) => {
        results.add(Post.fromJson(el))
      });
      return results;
    }
    return [];
  }
  static Future<List<Post>> fetchCreatedPosts(int userId) async {
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}:5001",'/createdposts', 
      {
        "user_id": userId
      }
    );
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final dataList = jsonDecode(response.body);
      List<Post> results = [];
      dataList.forEach((el) => {
        results.add(Post.fromJson(el))
      });
      
      return results;
    }
    return [];
  }
  static Future<List<Post>> fetchRegisteredPosts(int userId) async {
    return [
        Post(
          userId: 21, 
          postId: 22, 
          title: "Chicken Rice", 
          imageUrl: "https://www.innit.com/public/recipes/images/1033246--742330450-en-US-0_s1000.jpg", 
          locationDescription: "My mother's house", 
          locationLatitude: 2, 
          locationLongitude: 2, 
          availableReservations: 22, 
          totalReservations: 23, 
          createdAt: DateTime.parse("2023-04-28T06:43:24"), 
          timeEnd: DateTime.parse("2023-04-28T06:43:24"), 
          isAvailable: true
        ),
        Post(
          userId: 21, 
          postId: 23, 
          title: "Nasi Lemak", 
          imageUrl: "https://www.innit.com/public/recipes/images/1033246--742330450-en-US-0_s1000.jpg", 
          locationDescription: "My mother's house", 
          locationLatitude: 2, 
          locationLongitude: 2, 
          availableReservations: 22, 
          totalReservations: 23, 
          createdAt: DateTime.parse("2023-04-28T06:43:24"), 
          timeEnd: DateTime.parse("2023-04-28T06:43:24"), 
          isAvailable: true
          )
      ];
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}:5001",'/reservations/all/$userId');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final dataList = jsonDecode(response.body);
      List<Post> results = [];
      dataList.forEach((el) => {
        results.add(Post.fromJson(el))
      });
      return results;
    }
    return [];
  }

  static Future<void> reserveSnack(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? bearer = prefs.getString('bearerToken');
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}:5001",'/reserve');
    // short circuit
    // should fetch data again from 
    return ;
  }

  static Future<Post?> uploadPost(
    String title, 
    String locationDesc, 
    String servings,
    String expiryTime,
    int userId,
    XFile image,
    LocationData locationData
  ) async {
      // user_id, lat/long, 
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('bearerToken');
    final bytes = await image.readAsBytes();
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}:5001",'/createpost');
    var response = await http.post(
      url,
      body: jsonEncode({
        'title': title,
        'user_id': userId,
        'location_description': locationDesc,
        'location_latitude': locationData.latitude,
        'location_longitude': locationData.longitude,
        'available_reservations': servings,
        'time_end': expiryTime,
        'image_bytes': bytes
      }),
      headers: {
        "Authorization": "Bearer: $bearer",
        "Content-Type": "application/json"
      }
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final post = Post.fromJson(data);
      post.availableReservations = int.parse(servings);
      return post;
    }
    return null;
  }

}