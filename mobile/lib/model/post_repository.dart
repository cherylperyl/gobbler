import 'dart:convert';
import 'dart:ffi';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class PostRepository {
  static Future<List<Post>> fetchPosts(double long, double lat, int userId) async {
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/post/viewposts', {"latitude": "$lat", "longitude": "$long", "user_id": "$userId"});
    var response = await http.get(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final dataList = jsonDecode(response.body);
      print(dataList);
      List<Post> results = [];
      dataList.forEach((el) => {
        if (DateTime.parse(el['time_end']).compareTo(DateTime.now()) > 0) {
          results.add(Post.fromJson(el))
        }
        
      });
      return results;
    }
    return [];
  }
  static Future<List<Post>> fetchCreatedPosts(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('bearerToken');
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/post/createdpost', 
      {
        "user_id": '$userId'
      }
    );
    var response = await http.get(url, headers: {'Authorization': '$bearer'});
    print(url);
    print(response.body);
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
  static Future<List<dynamic>> fetchRegisteredPosts(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('bearerToken');
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/reservation/reservations/all/${userId}', 
    );
    var response = await http.get(url, headers: {'Authorization': '$bearer'});
    print(url);
    print(response.body);
    if (response.statusCode == 200) {
      final dataList = jsonDecode(response.body);
      return dataList;
    }
    return [];
  }

  static Future<bool> reservePost(num postId, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? bearer = prefs.getString('bearerToken');
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/reservation/reserve');
    var response = await http.post(url, 
      body: jsonEncode(
        { 
          "user_id": "$userId", 
          "post_id": "$postId"
          }
      ),
      headers: {
        'Authorization': '$bearer', 
        'Content-Type': 'application/json'
      }
    );
    print(url);
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<bool> cancelReservation(int reservationId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? bearer = prefs.getString('bearerToken');
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/reservation/reserve/cancel', {
      "reservation_id": '$reservationId'
    });
    var response = await http.delete(url, 
      headers: {
        'Authorization': '$bearer', 
        'Content-Type': 'application/json'
      },
    );
    print(url);
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    }
    return false;

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
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('bearerToken');
    final bytes = await image.readAsBytes();
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/post/createpost');
    var request = http.MultipartRequest('POST', url);
    print(bearer);
    request.fields['title'] = title;
    request.fields['post_desc'] =  locationDesc;
    request.fields['location_latitude'] = '${locationData.latitude}';
    request.fields['location_longitude'] = '${locationData.longitude}';
    request.fields['total_reservations'] = servings;
    request.fields['time_end'] = expiryTime;
    request.fields['user_id'] = '$userId';
    request.headers.addAll({ 'Authorization': '$bearer' });
    
    String fileType = image.path.split('.').last;
  
    final uploadImage = await http.MultipartFile.fromBytes(
        'image_file', bytes, filename: "filename", contentType: MediaType('image', fileType));
    request.files.add(uploadImage);
    
    try {
    // Send request and get response
      var response = await request.send();
      final respStr = await response.stream.bytesToString();

    // Check response status code
      if (response.statusCode == HttpStatus.ok) {
        // Success
        print('Post created successfully!');
        print(respStr);
        final json = jsonDecode(respStr);
        Post post = Post.fromJson(json);
        post.availableReservations = post.totalReservations;
        return post;
        
      } else {
        // Error
        print('Error creating post!');
        print(respStr);
        
        return null;
      }
    } catch (e) {
      print('Error submitting request: $e');
      return null;
    }
  
}
static Future<Post?> updatePost(
    num postId,
    String title, 
    String locationDesc, 
    String servings,
    String expiryTime,
    int userId,
    XFile image,
    LocationData locationData
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('bearerToken');
    final bytes = await image.readAsBytes();
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/post/updatepost', {"post_id": '$postId'});
    var request = http.MultipartRequest('POST', url);
    print(bearer);
    request.fields['title'] = title;
    request.fields['post_desc'] =  locationDesc;
    request.fields['location_latitude'] = '${locationData.latitude}';
    request.fields['location_longitude'] = '${locationData.longitude}';
    request.fields['total_reservations'] = servings;
    request.fields['time_end'] = expiryTime;
    request.fields['user_id'] = '$userId';
    request.headers.addAll({ 'Authorization': '$bearer' });
    
    String fileType = image.path.split('.').last;
  
    final uploadImage = await http.MultipartFile.fromBytes(
        'image_file', bytes, filename: "filename", contentType: MediaType('image', fileType));
    request.files.add(uploadImage);
    
    try {
    // Send request and get response
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      print(response.statusCode);

    // Check response status code
      if (response.statusCode == HttpStatus.ok) {
        // Success
        print('Post updated successfully!');
        print(respStr);
        final json = jsonDecode(respStr);
        final post = Post.fromJson(json);
        return post;
        
      } else {
        // Error
        print('Error updating post!');
        print(response.statusCode);
        
        return null;
      }
    } catch (e) {
      print('Error submitting request: $e');
      return null;
    }
}

static Future<Post?> hidePost(
    num postId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('bearerToken');
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/post/updatepost', {"post_id": '$postId'});
    var request = http.MultipartRequest('POST', url);
    request.fields['is_available'] = 'false';

    request.headers.addAll({ 'Authorization': '$bearer' });
    try {
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      print(respStr);
      if (response.statusCode == HttpStatus.ok) {
        print ("Post hidden successfully");
        print('response $respStr');
        final json = jsonDecode(respStr);
        final post = Post.fromJson(json);
        return post;
      } else {
        print('Error hiding post!');
        
        return null;
      }
    } catch (e) {
      print('Error submitting request: $e');
      return null;
    }
  
}
 

}